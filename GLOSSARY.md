# 🔤 Flutter Mastery Handbook — Glossary

> Alphabetical reference of every important term used throughout this handbook.

---

## A

**AOT (Ahead-of-Time) Compilation** — Dart compiles to native machine code before execution. Used in release builds for maximum performance.

**AnimationController** — A special controller that generates values over a given duration. Drives explicit animations in Flutter.

**async / await** — Dart keywords for writing asynchronous code in a synchronous style. `async` marks a function as asynchronous; `await` pauses until a Future completes.

**App Lifecycle** — The states a Flutter app transitions through: `inactive`, `paused`, `resumed`, `detached`, `hidden`.

---

## B

**Bloc (Business Logic Component)** — A state management pattern that uses Streams to separate business logic from UI. Events go in, states come out.

**BuildContext** — An object that represents the location of a widget in the widget tree. Used to look up inherited data and navigate.

**Builder Pattern** — A design pattern where a complex object is constructed step-by-step. In Flutter: `FutureBuilder`, `StreamBuilder`, `LayoutBuilder`.

---

## C

**Cascade Notation (`..`)** — Dart syntax that allows multiple operations on the same object without repeating the reference.

**ChangeNotifier** — A class in Flutter that provides change notification to listeners. Backbone of the Provider pattern.

**Completer** — A Dart class that lets you create a Future and complete it later with a value or error.

**Compositing** — The phase in Flutter's rendering pipeline where painted layers are combined into a final image.

**const Constructor** — A constructor that produces compile-time constant instances. Critical for widget rebuild optimization.

**Cubit** — A simpler variant of Bloc that uses functions instead of events to emit new states.

---

## D

**Dart** — The programming language used to write Flutter apps. A client-optimized, null-safe, strongly-typed language.

**Dart DevTools** — A suite of performance and debugging tools for Dart and Flutter applications.

**Deep Linking** — Direct navigation to a specific screen/resource via a URL, supported on iOS (Universal Links), Android (App Links), and Web.

**Deferred Components** — Split large apps into downloadable modules to reduce initial install size.

**Dependency Injection (DI)** — A technique where objects receive their dependencies from external sources rather than creating them. Common libraries: `get_it`, `injectable`.

**DevTools** — See *Dart DevTools*.

**Dio** — A powerful HTTP networking library for Dart with interceptors, retry logic, FormData, and cancellation.

**Drift** — A reactive persistence library for Dart/Flutter (formerly Moor). Generates type-safe SQL code.

---

## E

**Element** — The instantiation of a Widget in the element tree. Acts as the bridge between the widget tree and the render tree.

**EventChannel** — A Flutter platform channel for streaming data from native → Dart (e.g., sensor readings).

**Extension Methods** — Dart feature that lets you add new functionality to existing classes without modifying them.

---

## F

**Flame** — A modular 2D game engine built on top of Flutter.

**Flutter** — Google's open-source UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.

**FutureBuilder** — A widget that builds itself based on the latest snapshot of a Future.

---

## G

**GetX** — A lightweight Flutter solution for state management, navigation, and dependency injection.

**GlobalKey** — A key that is unique across the entire app. Allows access to the state of a widget from anywhere.

**GoRouter** — A declarative routing package for Flutter, built on Navigator 2.0, with deep linking support.

**Golden Test** — A test that compares a widget's rendered output to a pre-approved reference image.

---

## H

**Hero Animation** — A built-in Flutter animation that moves a widget from one screen to another with a smooth transition.

**Hive** — A lightweight, NoSQL, key-value database for Flutter, written in pure Dart. Very fast.

**Hot Reload** — Flutter's ability to inject updated source code into a running Dart VM, preserving state. Sub-second feedback.

**Hot Restart** — Restarts the app from scratch but faster than a cold start. State is lost.

---

## I

**Impeller** — Flutter's new rendering engine (default since Flutter 3.16) that pre-compiles shaders to eliminate jank.

**InheritedWidget** — A special widget that efficiently propagates data down the widget tree. Foundation for Provider.

**Isolate** — Dart's mechanism for concurrency. Each isolate has its own memory and event loop.

---

## J

**JIT (Just-in-Time) Compilation** — Dart compiles code at runtime. Used in debug mode to enable Hot Reload.

**JSON Serialization** — Converting Dart objects to/from JSON. Common libraries: `json_serializable`, `freezed`.

---

## K

**Key** — An identifier for Widgets, Elements, and SemanticsNodes. Types: `ValueKey`, `ObjectKey`, `UniqueKey`, `GlobalKey`.

---

## L

**Layout** — The phase where Flutter calculates the size and position of every RenderObject.

**Lazy Loading** — Loading resources on demand rather than up front. Example: `ListView.builder`.

**Lottie** — A library for rendering Adobe After Effects animations as JSON in Flutter.

---

## M

**Material Design** — Google's design system. Flutter includes a comprehensive Material 3 widget library.

**Melos** — A tool for managing Dart/Flutter monorepos with multiple packages.

**MethodChannel** — A Flutter platform channel for calling native methods from Dart and vice versa.

**Mixin** — A way to reuse a class's code in multiple class hierarchies. Dart uses `mixin` keyword.

**MVVM** — Model-View-ViewModel architecture pattern commonly used in Flutter apps.

---

## N

**Navigator** — Flutter's stack-based routing system. Navigator 1.0 (imperative) and Navigator 2.0 (declarative).

**Null Safety** — Dart's type system feature where types are non-nullable by default. Use `?` for nullable types.

---

## O

**Overlay** — A stack of entries that float above other widgets. Used for tooltips, dropdowns, and custom popups.

---

## P

**Painting** — The phase where Flutter draws visual elements onto a canvas (after layout).

**Pigeon** — A code generator for type-safe platform channel communication between Flutter and native code.

**Platform Channel** — The mechanism for Flutter ↔ native (iOS/Android) communication.

**Provider** — A wrapper around InheritedWidget for state management. Simple and widely used.

**pub.dev** — The official package repository for Dart and Flutter packages.

---

## R

**RenderObject** — The object that handles layout and painting in Flutter's render tree.

**RepaintBoundary** — A widget that isolates repaints to its subtree, improving performance.

**Riverpod** — A reactive state management library by the Provider author. Compile-safe, testable, no BuildContext needed.

**Rive** — A real-time animation tool and runtime for Flutter (alternative to Lottie with interactivity).

---

## S

**Scaffold** — A Material Design layout structure providing app bars, drawers, FABs, bottom sheets, and snack bars.

**Sealed Class** — A Dart 3 feature that restricts which classes can extend/implement it. Used for exhaustive pattern matching.

**Shader** — A GPU program (GLSL/SKSL) used for custom visual effects in Flutter.

**SharedPreferences** — Simple key-value storage for primitive data types. Backed by NSUserDefaults (iOS) and SharedPreferences (Android).

**Sliver** — A portion of a scrollable area. Slivers enable advanced scroll effects (SliverAppBar, SliverList, SliverGrid).

**State** — Mutable data associated with a StatefulWidget. Managed by a State object.

**StatefulWidget** — A widget with mutable state that can change during its lifetime.

**StatelessWidget** — A widget with no mutable state. Purely a function of its configuration.

**Stream** — An asynchronous sequence of data events. Can be single-subscription or broadcast.

**StreamBuilder** — A widget that rebuilds itself based on the latest snapshot of a Stream.

---

## T

**Three Trees** — Flutter's architecture: Widget Tree → Element Tree → RenderObject Tree.

**Tree Shaking** — A compiler optimization that removes unused code from the final binary.

**Tween** — Defines a range of values (begin → end) for an animation.

---

## U

**Universal Links** — Apple's mechanism for deep linking on iOS.

---

## V

**ValueNotifier** — A simple ChangeNotifier that holds a single value.

---

## W

**Widget** — The basic building block of a Flutter UI. Describes the configuration for an Element.

**Widget Tree** — The hierarchy of widgets that describes the UI.

---

## X–Z

**YAML** — The configuration format used by `pubspec.yaml`, `analysis_options.yaml`, and CI config files.

---

[← Back to README](README.md) | [Cheat Sheets →](CHEATSHEETS.md)
