# Chapter 09 — Platform Integration

> **Goal**: Master Flutter's platform channel system for communicating with native iOS/Android code, handling permissions, and building custom plugins.

---

## Table of Contents

1. [Platform Channels Overview](#1-platform-channels-overview)
2. [MethodChannel](#2-methodchannel)
3. [EventChannel](#3-eventchannel)
4. [Pigeon — Type-Safe Channels](#4-pigeon--type-safe-channels)
5. [Permissions](#5-permissions)
6. [Common Native Integrations](#6-common-native-integrations)
7. [Building Custom Plugins](#7-building-custom-plugins)
8. [Federated Plugin Architecture](#8-federated-plugin-architecture)
9. [Common Pitfalls](#9-common-pitfalls)
10. [Interview Questions](#10-interview-questions)
11. [Practice Exercises](#11-practice-exercises)
12. [Resources](#12-resources)

---

## 1. Platform Channels Overview

```
┌──────────────────────────────────────────────────┐
│          Flutter  ←→  Native Communication       │
│                                                  │
│  ┌──────────┐    Channel    ┌──────────────┐     │
│  │  Dart    │ ◀───────────▶ │  Native      │     │
│  │  (Flutter)│              │  (iOS/Android)│     │
│  └──────────┘               └──────────────┘     │
│                                                  │
│  Channel Types:                                  │
│  ┌─────────────────┐  One-shot request/response  │
│  │  MethodChannel  │  Dart → Native → Dart       │
│  └─────────────────┘                             │
│  ┌─────────────────┐  Continuous data stream     │
│  │  EventChannel   │  Native → Dart (stream)     │
│  └─────────────────┘                             │
│  ┌─────────────────┐  Raw message passing        │
│  │ BasicMessage-   │  Bidirectional, any codec    │
│  │ Channel         │                             │
│  └─────────────────┘                             │
│                                                  │
│  Standard Codecs: JSON, binary, standard          │
│  (int, double, String, List, Map, Uint8List)     │
└──────────────────────────────────────────────────┘
```

---

## 2. MethodChannel

### Dart Side

```dart
class BatteryService {
  static const _channel = MethodChannel('com.example.app/battery');

  Future<int> getBatteryLevel() async {
    try {
      final int level = await _channel.invokeMethod('getBatteryLevel');
      return level;
    } on PlatformException catch (e) {
      throw Exception('Failed to get battery level: ${e.message}');
    }
  }

  Future<bool> isCharging() async {
    return await _channel.invokeMethod<bool>('isCharging') ?? false;
  }
}
```

### Android (Kotlin)

```kotlin
// MainActivity.kt
class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryLevel" -> {
                        val level = getBatteryLevel()
                        if (level != -1) {
                            result.success(level)
                        } else {
                            result.error("UNAVAILABLE", "Battery level not available", null)
                        }
                    }
                    "isCharging" -> {
                        result.success(isCharging())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun isCharging(): Boolean {
        val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
        return batteryManager.isCharging
    }
}
```

### iOS (Swift)

```swift
// AppDelegate.swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.example.app/battery",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { (call, result) in
            switch call.method {
            case "getBatteryLevel":
                UIDevice.current.isBatteryMonitoringEnabled = true
                let level = Int(UIDevice.current.batteryLevel * 100)
                result(level)
            case "isCharging":
                result(UIDevice.current.batteryState == .charging)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

---

## 3. EventChannel

For continuous data streams from native to Dart (sensor data, connectivity changes, etc.).

### Dart Side

```dart
class AccelerometerService {
  static const _channel = EventChannel('com.example.app/accelerometer');

  Stream<AccelerometerData> get readings {
    return _channel.receiveBroadcastStream().map((event) {
      final map = Map<String, double>.from(event);
      return AccelerometerData(
        x: map['x']!,
        y: map['y']!,
        z: map['z']!,
      );
    });
  }
}

class AccelerometerData {
  final double x, y, z;
  AccelerometerData({required this.x, required this.y, required this.z});
}
```

### Android (Kotlin)

```kotlin
class AccelerometerPlugin(private val context: Context) :
    EventChannel.StreamHandler {

    private var sensorManager: SensorManager? = null
    private var listener: SensorEventListener? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                events?.success(mapOf(
                    "x" to event.values[0].toDouble(),
                    "y" to event.values[1].toDouble(),
                    "z" to event.values[2].toDouble()
                ))
            }
            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        sensorManager?.registerListener(listener, accelerometer, SensorManager.SENSOR_DELAY_UI)
    }

    override fun onCancel(arguments: Any?) {
        sensorManager?.unregisterListener(listener)
    }
}
```

---

## 4. Pigeon — Type-Safe Channels

Pigeon generates platform channel code from a Dart API definition — no manual string channel names.

```yaml
dev_dependencies:
  pigeon: ^17.0.0
```

### Define API

```dart
// pigeons/messages.dart
import 'package:pigeon/pigeon.dart';

class SearchRequest {
  String? query;
  int? limit;
}

class SearchReply {
  String? result;
  List<String?>? suggestions;
}

@HostApi()
abstract class SearchApi {
  SearchReply search(SearchRequest request);
}

@FlutterApi()
abstract class SearchEventApi {
  void onSearchUpdate(SearchReply reply);
}
```

### Generate Code

```bash
dart run pigeon \
  --input pigeons/messages.dart \
  --dart_out lib/pigeon/messages.g.dart \
  --kotlin_out android/app/src/main/kotlin/Messages.g.kt \
  --swift_out ios/Runner/Messages.g.swift
```

This generates:
- Type-safe Dart ↔ Native communication
- No raw string channel names
- Compile-time error checking
- Auto-generated serialization

---

## 5. Permissions

```yaml
dependencies:
  permission_handler: ^11.3.0
```

```dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isPermanentlyDenied) {
      // Open app settings
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  Future<Map<Permission, PermissionStatus>> requestMultiple() async {
    return await [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
    ].request();
  }

  Future<bool> checkAndRequest(Permission permission) async {
    var status = await permission.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await permission.request();
      return status.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }
}
```

### Platform Configuration Required

```xml
<!-- Android: AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

```xml
<!-- iOS: Info.plist -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby places</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone for voice messages</string>
```

---

## 6. Common Native Integrations

### Camera

```yaml
dependencies:
  camera: ^0.11.0
  image_picker: ^1.1.0
```

```dart
// Simple image picker
final picker = ImagePicker();
final image = await picker.pickImage(
  source: ImageSource.camera,
  maxWidth: 1080,
  imageQuality: 85,
);
if (image != null) {
  final file = File(image.path);
  // Process image
}
```

### Biometrics

```yaml
dependencies:
  local_auth: ^2.2.0
```

```dart
final auth = LocalAuthentication();

final canCheck = await auth.canCheckBiometrics;
final isDeviceSupported = await auth.isDeviceSupported();
final availableBiometrics = await auth.getAvailableBiometrics();

final didAuth = await auth.authenticate(
  localizedReason: 'Authenticate to access your data',
  options: const AuthenticationOptions(
    stickyAuth: true,
    biometricOnly: false, // Allow PIN/pattern fallback
  ),
);
```

### Share

```yaml
dependencies:
  share_plus: ^9.0.0
```

```dart
await Share.share('Check out this app!');
await Share.shareXFiles([XFile(filePath)], text: 'My photo');
```

---

## 7. Building Custom Plugins

```bash
# Create plugin project
flutter create --template=plugin --platforms=android,ios my_plugin
```

### Plugin Structure

```
my_plugin/
├── lib/
│   ├── my_plugin.dart            # Public Dart API
│   └── my_plugin_method_channel.dart  # MethodChannel implementation
│   └── my_plugin_platform_interface.dart  # Platform interface
├── android/
│   └── src/main/kotlin/.../MyPlugin.kt
├── ios/
│   └── Classes/MyPlugin.swift
├── test/
└── example/
    └── lib/main.dart             # Example app
```

---

## 8. Federated Plugin Architecture

```
┌──────────────────────────────────────┐
│          Federated Plugin            │
│                                      │
│  my_plugin/                          │  App-facing package
│    └── depends on: my_plugin_platform_interface
│                                      │
│  my_plugin_platform_interface/       │  Platform interface
│    └── abstract API definition       │
│                                      │
│  my_plugin_android/                  │  Android implementation
│    └── implements interface          │
│                                      │
│  my_plugin_ios/                      │  iOS implementation
│    └── implements interface          │
│                                      │
│  my_plugin_web/                      │  Web implementation
│    └── implements interface          │
└──────────────────────────────────────┘
```

This allows independent teams to maintain platform implementations.

---

## 9. Common Pitfalls

### ❌ Not Handling Platform Exceptions
```dart
// Always wrap channel calls in try-catch
try {
  await platform.invokeMethod('nativeMethod');
} on PlatformException catch (e) {
  // Handle gracefully
} on MissingPluginException {
  // Plugin not available on this platform
}
```

### ❌ Calling Platform Channels on Wrong Thread
Android: channel calls must be on the main thread.

### ❌ Not Adding Permission Descriptions (iOS)
iOS will crash if you request a permission without an `NSUsageDescription` in Info.plist.

---

## 10. Interview Questions

### Q1: What are platform channels and how do they work?
**A**: Platform channels provide a message-passing mechanism between Dart and native code. Messages are encoded/decoded using standard codecs. `MethodChannel` for request/response, `EventChannel` for native→Dart streams, `BasicMessageChannel` for raw messages. Each channel has a unique string name.

### Q2: MethodChannel vs EventChannel — when to use which?
**A**: MethodChannel for one-shot operations (get battery level, take photo, check permission). EventChannel for continuous data streams (sensor readings, connectivity changes, GPS updates). MethodChannel is bidirectional; EventChannel is native→Dart only.

### Q3: What is Pigeon?
**A**: A code generation tool that creates type-safe platform channel code from a Dart API definition. Eliminates stringly-typed channel names, generates serialization, and provides compile-time error checking across Dart, Kotlin, and Swift.

### Q4: How does the federated plugin architecture work?
**A**: Splits a plugin into 3+ packages: app-facing (public API), platform interface (abstract definition), and platform-specific implementations (Android, iOS, Web). Allows independent teams to maintain platform code. Uses `PlatformInterface` for registration.

---

## 11. Practice Exercises

### Exercise 1: Battery Plugin
Create a plugin that reads battery level and charging status using MethodChannel. Implement for Android and iOS.

### Exercise 2: Sensor Stream
Use EventChannel to stream accelerometer data from the device to Flutter. Display real-time x/y/z values.

### Exercise 3: Permission Flow
Build a camera app that properly requests permissions with graceful handling for denied and permanently denied states.

---

## 12. Resources

- [Platform Channels Guide](https://docs.flutter.dev/platform-integration/platform-channels)
- [Pigeon](https://pub.dev/packages/pigeon)
- [Permission Handler](https://pub.dev/packages/permission_handler)
- [Developing Plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)

---

[← Previous: Animations](../08_animations/08_animations.md) | [Next: Performance →](../10_performance_optimization/10_performance_optimization.md) | [Back to README](../../README.md)
