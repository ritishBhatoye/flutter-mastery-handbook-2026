# Chapter 01 — Introduction to Flutter

> **Goal**: Understand what Flutter is, set up your development environment, and run your first app.

---

## Table of Contents

1. [What is Flutter?](#1-what-is-flutter)
2. [Why Flutter in 2026?](#2-why-flutter-in-2026)
3. [Dart Language Essentials](#3-dart-language-essentials)
4. [Installation & Setup](#4-installation--setup)
5. [IDE Setup](#5-ide-setup)
6. [Your First Flutter App](#6-your-first-flutter-app)
7. [Flutter Architecture Overview](#7-flutter-architecture-overview)
8. [Common Pitfalls](#8-common-pitfalls)
9. [Interview Questions](#9-interview-questions)
10. [Practice Exercises](#10-practice-exercises)
11. [Resources](#11-resources)

---

## 1. What is Flutter?

**Flutter** is Google's open-source UI toolkit for building **natively compiled** applications for **mobile** (iOS, Android), **web**, **desktop** (macOS, Windows, Linux), and **embedded** devices — all from a **single codebase**.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Language** | Dart (client-optimized, null-safe, strongly typed) |
| **Rendering** | Custom rendering engine (Impeller, 2026 default) |
| **Hot Reload** | Sub-second UI updates during development |
| **Compilation** | AOT (release) + JIT (debug) |
| **Platforms** | iOS, Android, Web, macOS, Windows, Linux |

### How Flutter Differs from Other Frameworks

```
┌─────────────────────────────────────────────────────────┐
│              Cross-Platform Framework Comparison         │
├─────────────┬──────────────┬──────────────┬─────────────┤
│             │  Flutter     │  React Native│  Native     │
├─────────────┼──────────────┼──────────────┼─────────────┤
│ UI Rendering│  Own engine  │  Native views│  Native     │
│ Language    │  Dart        │  JavaScript  │  Swift/Kotlin│
│ Performance │  Near-native │  Bridge      │  Native     │
│ Dev Speed   │  Very Fast   │  Fast        │  Slower     │
│ Code Share  │  95%+        │  85%+        │  0%         │
│ Bundle Size │  ~5-8 MB     │  ~7-10 MB    │  ~2-5 MB    │
└─────────────┴──────────────┴──────────────┴─────────────┘
```

### Flutter Architecture (High Level)

```
┌──────────────────────────────────────────────┐
│                 Your Flutter App              │
│              (Dart Framework Layer)           │
├──────────────────────────────────────────────┤
│            Flutter Framework (Dart)           │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌───────┐ │
│  │Material│ │Cupertino│ │Widgets │ │Render │ │
│  └────────┘ └────────┘ └────────┘ └───────┘ │
├──────────────────────────────────────────────┤
│            Flutter Engine (C/C++)             │
│  ┌────────┐ ┌────────┐ ┌────────┐           │
│  │Impeller│ │Dart VM │ │Platform│           │
│  │Renderer│ │ (JIT/  │ │Channels│           │
│  │        │ │  AOT)  │ │        │           │
│  └────────┘ └────────┘ └────────┘           │
├──────────────────────────────────────────────┤
│           Platform Embedder                   │
│  ┌─────┐ ┌───────┐ ┌─────┐ ┌──────┐        │
│  │ iOS │ │Android│ │ Web │ │Desktop│        │
│  └─────┘ └───────┘ └─────┘ └──────┘        │
└──────────────────────────────────────────────┘
```

---

## 2. Why Flutter in 2026?

### Market Position
- **500K+** apps built with Flutter on Google Play
- Used by **Google, BMW, Alibaba, ByteDance, Nubank, Toyota**
- **#1** cross-platform framework on GitHub by stars
- Fully stable on **Web**, **macOS**, **Windows**, **Linux**

### 2026 Advantages
1. **Impeller rendering engine** — No more shader jank, pre-compiled pipelines
2. **Dart 3.7+** — Records, patterns, sealed classes, macros (preview)
3. **WebAssembly (Wasm)** — Near-native performance on the web
4. **Hot Reload** — Still the fastest development feedback loop
5. **Single codebase** — 6 platforms from one Dart project
6. **Strong typing + null safety** — Fewer runtime crashes
7. **Growing ecosystem** — 40K+ packages on pub.dev

---

## 3. Dart Language Essentials

> Full deep dive in [Chapter 02](../02_dart_deep_dive/02_dart_deep_dive.md). Here's the quick primer.

### Why Dart?

Dart was chosen for Flutter because it supports:
- **AOT compilation** → Fast startup, small binary
- **JIT compilation** → Hot Reload in debug
- **Strong typing** with type inference
- **Null safety** by default
- **Async/await** with Futures and Streams
- **Isolates** for true parallelism

### Quick Syntax Overview

```dart
// Variables
var name = 'Flutter';        // Inferred as String
final version = 3.29;        // Runtime constant
const pi = 3.14159;          // Compile-time constant
int? nullableInt;             // Nullable type

// Functions
String greet(String name, {int? age}) {
  return 'Hello $name${age != null ? ', age $age' : ''}';
}

// Arrow syntax for single expressions
int add(int a, int b) => a + b;

// Classes
class Developer {
  final String name;
  final String language;

  const Developer({required this.name, this.language = 'Dart'});

  @override
  String toString() => '$name ($language)';
}

// Async
Future<String> fetchData() async {
  final response = await http.get(Uri.parse('https://api.example.com'));
  return response.body;
}

// Collections
final languages = ['Dart', 'Kotlin', 'Swift'];
final scores = {'Alice': 95, 'Bob': 87};
final unique = {1, 2, 3, 3}; // {1, 2, 3}
```

---

## 4. Installation & Setup

### Prerequisites

| Platform | Requirements |
|----------|-------------|
| **All** | Git, 8 GB RAM minimum |
| **macOS** | Xcode (for iOS), macOS 11+ |
| **Windows** | Windows 10/11 64-bit, Visual Studio (C++ tools) |
| **Linux** | Various dev libraries (see docs) |

### Step-by-Step Installation

#### macOS

```bash
# 1. Install Flutter SDK (recommended: via Homebrew)
brew install --cask flutter

# 2. Or manual download
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
export PATH="$HOME/flutter/bin:$PATH"  # Add to ~/.zshrc

# 3. Verify installation
flutter doctor

# 4. Install Xcode (for iOS)
xcode-select --install
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# 5. Accept Xcode license
sudo xcodebuild -license accept

# 6. Install CocoaPods
brew install cocoapods

# 7. Install Android Studio
brew install --cask android-studio
# Open Android Studio → SDK Manager → Install Android SDK, NDK, CMake

# 8. Run Flutter Doctor again
flutter doctor
```

#### Windows

```powershell
# 1. Download Flutter SDK from flutter.dev
# 2. Extract to C:\dev\flutter
# 3. Add C:\dev\flutter\bin to PATH

# 4. Install Git for Windows
winget install Git.Git

# 5. Install Android Studio
winget install Google.AndroidStudio

# 6. Install Visual Studio (for Windows desktop dev)
# Select "Desktop development with C++" workload

# 7. Verify
flutter doctor
```

#### Linux (Ubuntu/Debian)

```bash
# 1. Install dependencies
sudo apt update
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa

# 2. Download and extract Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 3. Install Android Studio
sudo snap install android-studio --classic

# 4. Install Chrome (for web dev)
sudo apt install -y google-chrome-stable

# 5. Verify
flutter doctor
```

### Flutter Doctor Output

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.29.x)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Android Studio
[✓] VS Code
[✓] Connected device (3 available)
[✓] Network resources

• No issues found!
```

> ⚠️ **Tip**: Fix all issues shown by `flutter doctor` before proceeding.

---

## 5. IDE Setup

### VS Code (Recommended)

#### Required Extensions
```
1. Flutter (Dart-Code.flutter)
2. Dart (Dart-Code.dart-code)
```

#### Recommended Extensions
```
3. Error Lens                    — Inline error display
4. Bracket Pair Color DLW        — Bracket matching
5. Material Icon Theme           — File icons
6. Pubspec Assist                — Dependency management
7. Flutter Riverpod Snippets     — Riverpod code snippets
8. bloc                         — Bloc snippets
9. GitLens                      — Git blame inline
```

#### VS Code Settings (settings.json)
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 80,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": "explicit"
  },
  "editor.rulers": [80],
  "dart.debugSdkLibraries": false,
  "dart.openDevTools": "flutter",
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.tabSize": 2,
    "editor.insertSpaces": true
  }
}
```

### Android Studio

1. Install **Flutter** and **Dart** plugins via `Preferences → Plugins`
2. Set Flutter SDK path: `Preferences → Languages → Flutter`
3. Enable hot reload on save: `Preferences → Flutter → Perform hot reload on save`

### Emulator Setup

#### Android Emulator
```bash
# Via Android Studio
# Tools → Device Manager → Create Device
# Select Pixel 7 Pro → API 34 (Android 14) → Finish

# Command line
flutter emulators --create --name Pixel_7_API34
flutter emulators --launch Pixel_7_API34
```

#### iOS Simulator (macOS only)
```bash
# Open Simulator
open -a Simulator

# List available simulators
xcrun simctl list devices

# Boot a specific device
xcrun simctl boot "iPhone 15 Pro"
```

### Flutter DevTools

```bash
# Launch DevTools
flutter pub global activate devtools
dart devtools

# Or from VS Code: Cmd+Shift+P → "Flutter: Open DevTools"
```

DevTools includes:
- **Widget inspector** — Explore the widget tree
- **Performance** — Frame rendering timeline
- **CPU Profiler** — Flame charts
- **Memory** — Heap snapshots, allocation tracking
- **Network** — HTTP request inspector
- **Logging** — Application logs

---

## 6. Your First Flutter App

### Create the Project

```bash
flutter create hello_flutter
cd hello_flutter
flutter run
```

### Project Structure

```
hello_flutter/
├── android/              ← Android native code
├── ios/                  ← iOS native code
├── lib/                  ← YOUR DART CODE LIVES HERE
│   └── main.dart         ← Entry point
├── linux/                ← Linux native code
├── macos/                ← macOS native code
├── web/                  ← Web entry point
├── windows/              ← Windows native code
├── test/                 ← Tests
│   └── widget_test.dart
├── pubspec.yaml          ← Dependencies & config
├── pubspec.lock          ← Lock file
└── analysis_options.yaml ← Linting rules
```

### Your First App Code

```dart
// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello Flutter'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Understanding What Happens

```
main()
  └── runApp(MyApp())
        └── MaterialApp
              └── HomePage (StatefulWidget)
                    └── Scaffold
                          ├── AppBar
                          ├── Body: Column
                          │    ├── Text (label)
                          │    └── Text (counter)
                          └── FAB (FloatingActionButton)
```

1. `main()` → Entry point, calls `runApp()`
2. `runApp()` → Inflates the root widget and attaches it to the screen
3. `MaterialApp` → Provides Material Design theming, navigation, localization
4. `Scaffold` → Basic Material layout structure (AppBar + Body + FAB)
5. `setState()` → Triggers a rebuild of the widget's subtree

---

## 7. Flutter Architecture Overview

### The Three Trees

Flutter maintains three parallel trees:

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Widget Tree │     │ Element Tree │     │ RenderObject │
│  (Config)    │────▶│  (Lifecycle) │────▶│    Tree      │
│              │     │              │     │  (Layout +   │
│  Immutable   │     │  Mutable     │     │   Paint)     │
│  Lightweight │     │  Long-lived  │     │  Expensive   │
└──────────────┘     └──────────────┘     └──────────────┘
```

- **Widget Tree**: The blueprint. Widgets are configuration objects — cheap to create and destroy.
- **Element Tree**: The instantiation. Elements manage the lifecycle and hold references to both widgets and render objects.
- **RenderObject Tree**: The worker. Handles layout (sizing and positioning) and painting.

### Rendering Pipeline

```
Build Phase → Layout Phase → Paint Phase → Compositing → Rasterize
    │              │              │              │            │
  Widgets      RenderBox      Canvas         Layers       Impeller
  rebuild      .performLayout  .paint()      compose      GPU render
```

> 📖 Deep dive in [Chapter 10 — Performance](../10_performance_optimization/10_performance_optimization.md)

---

## 8. Common Pitfalls

### ❌ Pitfall 1: Not Running `flutter doctor`
Always verify your setup before starting. Missing tools cause cryptic build errors.

### ❌ Pitfall 2: Outdated Flutter SDK
```bash
# Keep Flutter updated
flutter upgrade
flutter channel stable
```

### ❌ Pitfall 3: Huge `build()` Methods
Split large build methods into smaller widget classes for readability and performance.

### ❌ Pitfall 4: Ignoring `const` Constructors
```dart
// Bad — rebuilds every frame
child: Text('Hello')

// Good — cached by the framework
child: const Text('Hello')
```

### ❌ Pitfall 5: Using `print()` Instead of `debugPrint()`
`print()` can cause buffer overflow in debug mode. Use `debugPrint()` or `log()`.

### ❌ Pitfall 6: Not Setting Up Linting
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    prefer_single_quotes: true
```

---

## 9. Interview Questions

### Q1: What is Flutter and how does it differ from React Native?
**A**: Flutter is Google's UI toolkit that uses its own rendering engine (Impeller) to draw every pixel, achieving consistent UI across platforms. React Native uses a bridge to communicate with native components, which can cause performance issues. Flutter compiles to native ARM code via Dart AOT, while React Native uses JavaScript with a bridge.

### Q2: Explain Flutter's architecture layers.
**A**: Flutter has three layers:
1. **Framework (Dart)** — Widgets, Material/Cupertino libraries, rendering, animation, gestures
2. **Engine (C/C++)** — Impeller renderer, Dart VM, platform channels
3. **Embedder** — Platform-specific code to host the engine on each OS

### Q3: What are the three trees in Flutter?
**A**: Widget Tree (immutable configuration), Element Tree (mutable lifecycle management, bridges widget and render), RenderObject Tree (handles layout and painting). When a widget rebuilds, Flutter diffs the Widget Tree and updates the Element Tree minimally, only modifying RenderObjects when layout/paint actually changes.

### Q4: What is Hot Reload vs Hot Restart?
**A**:
- **Hot Reload**: Injects updated Dart source into the running VM, preserving app state. Sub-second. Only works for code inside `build()` and most method changes.
- **Hot Restart**: Restarts the app from `main()`, losing all state. Faster than cold start. Needed when state initialization changes.

### Q5: What is Impeller?
**A**: Impeller is Flutter's new rendering engine (default since 3.16). Unlike Skia, it pre-compiles all shaders during build time, eliminating first-frame jank. It uses Metal (iOS/macOS), Vulkan (Android), and OpenGL fallback.

### Q6: Explain the Flutter rendering pipeline.
**A**: Build (widget tree diff + rebuild) → Layout (RenderObject sizing via constraints-down, sizes-up) → Paint (Canvas drawing) → Compositing (Layer tree) → Rasterizing (GPU via Impeller).

### Q7: What is `pubspec.yaml`?
**A**: The project manifest file that defines: app name, description, version, SDK constraints, dependencies, dev_dependencies, assets, fonts, and Flutter-specific configuration.

### Q8: Can Flutter build for all platforms from a single codebase?
**A**: Yes — iOS, Android, Web, macOS, Windows, and Linux. However, platform-specific features (like iOS biometrics or Android intents) require platform channels or plugins.

---

## 10. Practice Exercises

### Exercise 1: Setup Verification
- [ ] Install Flutter SDK
- [ ] Run `flutter doctor` with all green checks
- [ ] Create a new project with `flutter create`
- [ ] Run on an emulator/simulator AND physical device
- [ ] Run on Chrome (web)

### Exercise 2: Modify the Counter App
1. Change the app theme to use `Colors.teal` as the seed color
2. Add a **decrement** button (second FAB or icon button)
3. Display the counter in a `Card` widget with rounded corners
4. Show a `SnackBar` when the counter reaches 10

### Exercise 3: Explore Project Structure
1. Open `pubspec.yaml` and add a description
2. Add an asset image and display it
3. Add a Google Font and use it in a `Text` widget
4. Run `flutter analyze` and fix all warnings

### Solutions

<details>
<summary>Exercise 2 Solution</summary>

```dart
class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _increment() {
    setState(() => _counter++);
    if (_counter == 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You reached 10! 🎉')),
      );
    }
  }

  void _decrement() {
    setState(() {
      if (_counter > 0) _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter App')),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              '$_counter',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _decrement,
            heroTag: 'dec',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _increment,
            heroTag: 'inc',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
```

</details>

---

## 11. Resources

### Official
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [DartPad](https://dartpad.dev/) — Online Dart/Flutter playground
- [Flutter Samples](https://github.com/flutter/samples)
- [Flutter YouTube Channel](https://www.youtube.com/@flutterdev)

### Courses
- [Flutter & Dart — The Complete Guide (Udemy/Academind)](https://www.udemy.com/course/learn-flutter-dart-to-build-ios-android-apps/)
- [Flutter Apprentice (Kodeco)](https://www.kodeco.com/books/flutter-apprentice)
- [Andrea Bizzotto — Flutter Foundations](https://codewithandrea.com/courses/flutter-foundations/)

### Community
- [Flutter Discord](https://discord.gg/flutter)
- [r/FlutterDev (Reddit)](https://www.reddit.com/r/FlutterDev/)
- [Flutter Community on Medium](https://medium.com/flutter-community)

---

[Next Chapter → Dart Deep Dive](../02_dart_deep_dive/02_dart_deep_dive.md) | [Back to README](../../README.md)
