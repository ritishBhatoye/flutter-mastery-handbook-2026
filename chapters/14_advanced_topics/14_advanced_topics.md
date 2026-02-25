# Chapter 14 — Flutter 2026 Advanced Topics

> **Goal**: Explore cutting-edge Flutter capabilities — Web, Desktop, Games, AI/ML integration, custom rendering, and shaders.

---

## Table of Contents

1. [Flutter Web](#1-flutter-web)
2. [Flutter Desktop](#2-flutter-desktop)
3. [Flutter Games (Flame)](#3-flutter-games-flame)
4. [AI/ML Integration](#4-aiml-integration)
5. [New Engine Features (2026)](#5-new-engine-features-2026)
6. [Custom Rendering & Shaders](#6-custom-rendering--shaders)
7. [FFI — Foreign Function Interface](#7-ffi--foreign-function-interface)
8. [WASM & Native Assets](#8-wasm--native-assets)
9. [Interview Questions](#9-interview-questions)
10. [Practice Exercises](#10-practice-exercises)
11. [Resources](#11-resources)

---

## 1. Flutter Web

### Build & Deploy

```bash
# Build for web
flutter build web --release

# With specific renderer
flutter build web --web-renderer canvaskit  # Better quality, larger bundle
flutter build web --web-renderer html       # Smaller, better SEO
flutter build web --web-renderer auto       # Default: html on mobile, canvaskit on desktop

# Deploy to Firebase Hosting
firebase init hosting
firebase deploy
```

### Web-Specific Considerations

```
┌───────────────────────────────────────────────────┐
│             Flutter Web Checklist                  │
│                                                   │
│ ✅ SEO: Use html renderer + semantic widgets       │
│ ✅ Loading: Add custom loading spinner to index.html│
│ ✅ Responsive: Use LayoutBuilder + breakpoints     │
│ ✅ URLs: GoRouter handles browser back/forward     │
│ ✅ Performance: Deferred loading for large features│
│ ✅ PWA: Configure manifest.json + service worker   │
│ ⚠️ Bundle size: CanvasKit adds ~2MB                │
│ ⚠️ Text selection: SelectableText for copyable text│
│ ⚠️ Accessibility: Semantic widgets for screen readers│
└───────────────────────────────────────────────────┘
```

### Responsive Web Layout

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) return desktop;
        if (constraints.maxWidth >= 768) return tablet ?? desktop;
        return mobile;
      },
    );
  }
}
```

### Conditional Imports

```dart
// Conditional platform imports
import 'stub_web.dart'
    if (dart.library.html) 'web_impl.dart'
    if (dart.library.io) 'io_impl.dart';
```

---

## 2. Flutter Desktop

### Setup

```bash
# Enable desktop (should be enabled by default in 2026)
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop

# Create app
flutter create my_desktop_app
cd my_desktop_app
flutter run -d macos  # or -d windows, -d linux
```

### Desktop-Specific Features

```dart
// Window management
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    title: 'My Desktop App',
    titleBarStyle: TitleBarStyle.hidden, // Custom title bar
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}
```

### Menu Bar

```dart
PlatformMenuBar(
  menus: [
    PlatformMenu(
      label: 'File',
      menus: [
        PlatformMenuItem(
          label: 'New',
          shortcut: const SingleActivator(LogicalKeyboardKey.keyN, meta: true),
          onSelected: () => _createNew(),
        ),
        PlatformMenuItem(
          label: 'Open',
          shortcut: const SingleActivator(LogicalKeyboardKey.keyO, meta: true),
          onSelected: () => _openFile(),
        ),
        const PlatformMenuItemGroup(members: [
          PlatformMenuItem(label: 'Quit', shortcut: SingleActivator(
            LogicalKeyboardKey.keyQ, meta: true,
          )),
        ]),
      ],
    ),
  ],
  child: const MyApp(),
)
```

### Keyboard Shortcuts

```dart
Shortcuts(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
        const SaveIntent(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
        const UndoIntent(),
  },
  child: Actions(
    actions: {
      SaveIntent: CallbackAction<SaveIntent>(
        onInvoke: (_) => _save(),
      ),
      UndoIntent: CallbackAction<UndoIntent>(
        onInvoke: (_) => _undo(),
      ),
    },
    child: const MyApp(),
  ),
)
```

---

## 3. Flutter Games (Flame)

```yaml
dependencies:
  flame: ^1.17.0
```

### Basic Game

```dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class SpaceGame extends FlameGame with TapCallbacks {
  late Player player;
  late TextComponent scoreText;
  int score = 0;

  @override
  Future<void> onLoad() async {
    // Load assets
    await images.loadAll(['player.png', 'enemy.png', 'bullet.png']);

    // Add player
    player = Player()
      ..position = Vector2(size.x / 2, size.y - 100)
      ..size = Vector2(64, 64)
      ..anchor = Anchor.center;
    add(player);

    // Score display
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
    add(scoreText);

    // Spawn enemies
    add(EnemySpawner());
  }

  @override
  void update(double dt) {
    super.update(dt);
    scoreText.text = 'Score: $score';
  }

  @override
  void onTapDown(TapDownEvent event) {
    player.shoot();
  }

  void addScore(int points) {
    score += points;
  }
}

// Player component
class Player extends SpriteComponent with HasGameRef<SpaceGame> {
  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('player.png');
  }

  void shoot() {
    gameRef.add(Bullet()
      ..position = position.clone()
      ..size = Vector2(8, 20));
  }

  void move(Vector2 delta) {
    position.add(delta);
    position.x = position.x.clamp(0, gameRef.size.x);
  }
}

// Flutter widget wrapper
class GameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GameWidget(game: SpaceGame());
  }
}
```

### Collision Detection

```dart
class Bullet extends SpriteComponent
    with HasGameRef<SpaceGame>, CollisionCallbacks {
  final double speed = -500;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('bullet.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    position.y += speed * dt;
    if (position.y < -50) removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is Enemy) {
      gameRef.addScore(10);
      other.removeFromParent();
      removeFromParent();
    }
  }
}
```

---

## 4. AI/ML Integration

### TensorFlow Lite

```yaml
dependencies:
  tflite_flutter: ^0.10.0
```

```dart
class ImageClassifier {
  late Interpreter _interpreter;
  late List<String> _labels;

  Future<void> init() async {
    _interpreter = await Interpreter.fromAsset('model.tflite');
    _labels = await _loadLabels('assets/labels.txt');
  }

  Future<String> classify(img.Image image) {
    // Resize image to model input size
    final resized = img.copyResize(image, width: 224, height: 224);

    // Convert to input tensor
    final input = _imageToByteList(resized);

    // Run inference
    final output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);
    _interpreter.run(input, output);

    // Find top prediction
    final results = output[0] as List<double>;
    final maxIndex = results.indexOf(results.reduce(max));
    return _labels[maxIndex];
  }

  void dispose() => _interpreter.close();
}
```

### Google ML Kit

```yaml
dependencies:
  google_mlkit_text_recognition: ^0.13.0
  google_mlkit_face_detection: ^0.11.0
  google_mlkit_barcode_scanning: ^0.12.0
```

```dart
// Text recognition (OCR)
final recognizer = TextRecognizer();
final inputImage = InputImage.fromFilePath(imagePath);
final result = await recognizer.processImage(inputImage);

for (final block in result.blocks) {
  for (final line in block.lines) {
    print('Recognized: ${line.text}');
  }
}

recognizer.close();
```

### LLM Integration

```dart
// Using Google Gemini API
class AIService {
  final Dio _dio;
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  AIService(this._dio);

  Future<String> chat(String prompt) async {
    final response = await _dio.post(
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent',
      queryParameters: {'key': _apiKey},
      data: {
        'contents': [
          {
            'parts': [{'text': prompt}]
          }
        ],
      },
    );

    return response.data['candidates'][0]['content']['parts'][0]['text'];
  }
}
```

---

## 5. New Engine Features (2026)

### Impeller — Default Rendering Engine

- Pre-compiled shaders (no jank)
- Multi-threaded rendering
- Native Metal (iOS) and Vulkan (Android) support
- Better 120 FPS support

### Dart 3.x Features

```dart
// Sealed classes + exhaustive pattern matching
sealed class Shape {}
class Circle extends Shape { final double radius; Circle(this.radius); }
class Rectangle extends Shape { final double w, h; Rectangle(this.w, this.h); }

double area(Shape shape) => switch (shape) {
  Circle(radius: final r) => 3.14159 * r * r,
  Rectangle(w: final w, h: final h) => w * h,
};

// Records
(String, int) getNameAndAge() => ('Alice', 30);

final (name, age) = getNameAndAge();

// Extension types (zero-cost wrapper)
extension type Meters(double value) {
  Meters operator +(Meters other) => Meters(value + other.value);
  Kilometers toKilometers() => Kilometers(value / 1000);
}

// Macros (experimental — code generation at compile time)
@DataClass()
class User {
  final String name;
  final int age;
}
// Auto-generates: constructor, copyWith, ==, hashCode, toString
```

---

## 6. Custom Rendering & Shaders

### Fragment Shaders (GLSL)

```glsl
// shaders/ripple.frag
#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform vec2 uSize;
uniform vec2 uCenter;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 center = uCenter / uSize;

  float dist = distance(uv, center);
  float wave = sin(dist * 40.0 - uTime * 5.0) * 0.5 + 0.5;

  vec3 color = mix(
    vec3(0.1, 0.2, 0.8),
    vec3(0.8, 0.2, 0.5),
    wave
  );

  fragColor = vec4(color, 1.0);
}
```

### Using Shaders in Flutter

```dart
class ShaderWidget extends StatefulWidget {
  @override
  State<ShaderWidget> createState() => _ShaderWidgetState();
}

class _ShaderWidgetState extends State<ShaderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _loadShader();
  }

  Future<void> _loadShader() async {
    final program = await FragmentProgram.fromAsset('shaders/ripple.frag');
    setState(() => _shader = program.fragmentShader());
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) return const SizedBox();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ShaderPainter(
            shader: _shader!,
            time: _controller.value * 10,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ShaderPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;

  ShaderPainter({required this.shader, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, time);                // uTime
    shader.setFloat(1, size.width);          // uSize.x
    shader.setFloat(2, size.height);         // uSize.y
    shader.setFloat(3, size.width / 2);      // uCenter.x
    shader.setFloat(4, size.height / 2);     // uCenter.y

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(ShaderPainter oldDelegate) => time != oldDelegate.time;
}
```

---

## 7. FFI — Foreign Function Interface

Call C/C++ libraries directly from Dart (no platform channels — near-native speed).

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Load C library
final dylib = DynamicLibrary.open('libnative.so');

// Define C function signature
typedef NativeAdd = Int32 Function(Int32, Int32);
typedef DartAdd = int Function(int, int);

// Lookup and bind
final add = dylib.lookupFunction<NativeAdd, DartAdd>('add');

// Call it
final result = add(3, 4); // 7
```

---

## 8. WASM & Native Assets

### Native Assets (Dart 3.2+)

```yaml
# pubspec.yaml
native_assets:
  - src/native/my_lib.c
```

Build system automatically compiles C/C++/Rust and links it — no manual build scripts.

### WASM (Web Assembly)

```bash
# Compile Dart to WASM for web
flutter build web --wasm
```

Benefits: Faster execution than JavaScript on web, smaller bundle in some cases.

---

## 9. Interview Questions

### Q1: How does Flutter Web differ from mobile?
**A**: Same widget code, but rendered via HTML/CSS or CanvasKit in the browser. Considerations: no file system access, different text rendering, SEO challenges (CanvasKit is canvas-based), larger initial load. Use html renderer for content sites, CanvasKit for complex visualizations.

### Q2: What is Dart FFI and when to use it?
**A**: FFI (Foreign Function Interface) allows calling C/C++/Rust functions directly from Dart with near-native performance — no platform channel overhead. Use for: heavy computation (image processing, cryptography), reusing existing native libraries, performance-critical code.

### Q3: How do custom shaders work in Flutter?
**A**: Write GLSL fragment shaders, compile them via `FragmentProgram.fromAsset()`. Pass uniforms (time, size, colors) via `setFloat()`. Paint with `Canvas.drawRect()` using `Paint()..shader`. Runs on GPU via Impeller — ideal for visual effects, backgrounds, transitions.

---

## 10. Practice Exercises

### Exercise 1: Responsive Portfolio
Build a portfolio website with Flutter Web. Responsive: mobile sidebar → desktop navigation. Deploy to Firebase.

### Exercise 2: Simple Game
Build a "Flappy Bird" clone with Flame engine. Gravity, tap to flap, pipes, score, game over.

### Exercise 3: Shader Effect
Create a water ripple shader effect that responds to touch position + animates over time.

---

## 11. Resources

- [Flutter Web Guide](https://docs.flutter.dev/platform-integration/web)
- [Flutter Desktop](https://docs.flutter.dev/platform-integration/desktop)
- [Flame Engine](https://docs.flame-engine.org/)
- [Fragment Shaders](https://docs.flutter.dev/ui/design/graphics/fragment-shaders)
- [Dart FFI](https://dart.dev/interop/c-interop)
- [TFLite Flutter](https://pub.dev/packages/tflite_flutter)
- [Google ML Kit](https://pub.dev/packages/google_mlkit_commons)

---

[← Previous: Real Projects](../13_real_projects/13_real_projects.md) | [Next: Interview Guide →](../15_interview_guide/15_interview_guide.md) | [Back to README](../../README.md)
