# Chapter 15 — Interview Guide

> **Goal**: Comprehensive interview preparation — Flutter, Dart, Architecture, System Design, and Behavioral questions with model answers.

---

## Table of Contents

1. [Interview Strategy](#1-interview-strategy)
2. [Core Dart Questions](#2-core-dart-questions)
3. [Core Flutter Questions](#3-core-flutter-questions)
4. [State Management Questions](#4-state-management-questions)
5. [Architecture Questions](#5-architecture-questions)
6. [Performance Questions](#6-performance-questions)
7. [System Design for Mobile](#7-system-design-for-mobile)
8. [Behavioral Questions](#8-behavioral-questions)
9. [Live Coding Tips](#9-live-coding-tips)
10. [Quick Revision Sheet](#10-quick-revision-sheet)

---

## 1. Interview Strategy

```
┌──────────────────────────────────────────────────┐
│           Flutter Interview Stages               │
│                                                  │
│  Round 1: Online Assessment / Screening          │
│     • Dart fundamentals, basic Flutter           │
│     • 30-60 min coding challenge                 │
│                                                  │
│  Round 2: Technical Deep Dive                    │
│     • Widget tree, lifecycle, state management   │
│     • Code review or live coding                 │
│     • 45-60 min                                  │
│                                                  │
│  Round 3: Architecture & System Design           │
│     • Design a Flutter app at scale              │
│     • Trade-off discussions                      │
│     • 45-60 min                                  │
│                                                  │
│  Round 4: Behavioral / Culture Fit               │
│     • Past experience, leadership, conflict      │
│     • 30-45 min                                  │
└──────────────────────────────────────────────────┘
```

---

## 2. Core Dart Questions

### Q1: What is sound null safety?
**A**: All types are non-nullable by default. You must explicitly mark nullable types with `?`. The compiler guarantees no null reference errors at runtime. Operators: `?.` (null check), `??` (default), `!` (assertion).

```dart
String name = 'Flutter';     // Cannot be null
String? nickname;            // Can be null
final length = nickname?.length ?? 0;
```

### Q2: Explain Dart's event loop.
**A**: Dart is single-threaded with an event loop and two queues:
1. **Microtask queue** — high priority (Future.microtask, scheduleMicrotask). Runs between events.
2. **Event queue** — I/O, timers, gestures, Futures.

```
┌──────────────────────────────────────┐
│         Dart Event Loop              │
│                                      │
│  main() → │                          │
│           ▼                          │
│  ┌──── Microtask Queue? ─── Yes ──┐ │
│  │        (process all)           │ │
│  │   No   ◄───────────────────────┘ │
│  ▼                                   │
│  ┌──── Event Queue? ─── Yes ──────┐ │
│  │     (process one)              │ │
│  │   No   ◄───────────────────────┘ │
│  ▼                                   │
│  (idle / wait for events)            │
│  ← loops back to microtask check     │
└──────────────────────────────────────┘
```

### Q3: What are isolates and when to use them?
**A**: Isolates are independent Dart execution contexts with their own memory and event loop. They DON'T share memory — communicate via message passing (SendPort/ReceivePort). Use for: heavy computation (JSON parsing, image processing), crypto operations, long-running tasks. In Flutter, use `Isolate.run()` or `compute()` for simple cases.

### Q4: Explain records and patterns (Dart 3).
**A**: Records are anonymous, immutable, fixed-size collections. Patterns enable destructuring and match checking.

```dart
// Record
(String, int, {bool isActive}) user = ('Alice', 30, isActive: true);
final (name, age, isActive: active) = user; // Destructure

// Pattern matching
switch (shape) {
  case Circle(radius: final r) when r > 0:
    print('Circle with radius $r');
  case Rectangle(w: final w, h: final h):
    print('Rectangle $w x $h');
}
```

### Q5: What are sealed classes?
**A**: Sealed classes restrict which classes can extend them — only in the same library. The compiler knows ALL subtypes, enabling exhaustive `switch` without a `default` case. Used for: state types (AuthState), event types (AuthEvent), sealed hierarchies.

### Q6: Explain extension types.
**A**: Zero-cost wrappers around existing types that add a new API without runtime overhead. The wrapper is erased at compile time.

```dart
extension type UserId(String value) {
  bool get isValid => value.isNotEmpty;
}
// UserId is treated as String at runtime — no boxing/allocation
```

### Q7: What is `late` keyword?
**A**: `late` means the variable will be initialized before first use (deferred initialization). The compiler trusts you — throws `LateInitializationError` if accessed before assignment.

```dart
late String _name;

@override
void initState() {
  super.initState();
  _name = fetchName(); // Initialized here, but declared earlier
}
```

### Q8: Difference between `const` and `final`?
**A**: `final` = set once at runtime. `const` = compile-time constant. `const` values are canonicalized (only one instance in memory). `const` constructors allow creating compile-time widget instances.

---

## 3. Core Flutter Questions

### Q9: Explain the three trees in Flutter.
**A**:
1. **Widget tree** — Immutable configuration (what you write in `build()`). Rebuilt frequently. Cheap.
2. **Element tree** — Mutable linking between Widget and RenderObject. Manages lifecycle. Persistent.
3. **RenderObject tree** — Handles layout and painting. Expensive. Reused when possible.

```
Widget Tree          Element Tree         RenderObject Tree
┌──────────┐        ┌──────────┐         ┌──────────────┐
│Container │───────▶│ContainerE│────────▶│RenderDecora- │
│          │        │          │         │tedBox        │
└──┬───────┘        └──┬───────┘         └──┬───────────┘
   │                   │                    │
┌──▼───────┐        ┌──▼───────┐         ┌──▼───────────┐
│  Text    │───────▶│  TextE   │────────▶│RenderPara-   │
│          │        │          │         │graph          │
└──────────┘        └──────────┘         └──────────────┘
```

### Q10: What is BuildContext?
**A**: BuildContext is a reference to the Element in the Element tree. It represents the widget's position and allows access to: theme data, media queries, inherited widgets, navigation. Every `build()` receives its widget's BuildContext.

### Q11: StatelessWidget vs StatefulWidget — difference?
**A**: StatelessWidget — immutable, no internal state. `build()` only depends on constructor params. StatefulWidget — has mutable state in a `State` object that persists across rebuilds. Use StatefulWidget when UI needs to change in response to user interaction or async data.

### Q12: Explain the StatefulWidget lifecycle.
**A**:
1. `createState()` → creates the State object
2. `initState()` → one-time setup (subscriptions, controllers)
3. `didChangeDependencies()` → called when InheritedWidget changes
4. `build()` → returns widget tree (called on every setState)
5. `didUpdateWidget()` → parent rebuilt with new widget instance
6. `setState()` → mark state dirty, schedule rebuild
7. `deactivate()` → removed from tree temporarily
8. `dispose()` → cleanup (cancel subscriptions, dispose controllers)

### Q13: What is a Key and when to use it?
**A**: Keys help Flutter identify which Elements to reuse when the widget tree changes. Types:
- `ValueKey` — identify by value (e.g., item ID in a list)
- `ObjectKey` — identify by object reference
- `UniqueKey` — always creates a new Element
- `GlobalKey` — access widget state from anywhere (use sparingly)

Use when: reordering lists, AnimatedSwitcher, preserving state across reparenting.

### Q14: What are Slivers?
**A**: Slivers are scrollable pieces of UI that implement the "sliver protocol" — a contract for lazy building of scrollable content. SliverList, SliverGrid, SliverAppBar, SliverToBoxAdapter. Used in CustomScrollView for complex scroll layouts (collapsing headers, mixed lists/grids).

### Q15: Navigator 1.0 vs 2.0?
**A**: Navigator 1.0 is imperative (push/pop). Navigator 2.0 is declarative (list of Pages). GoRouter wraps 2.0 with a simple API and handles deep linking, web URLs, and auth guards.

---

## 4. State Management Questions

### Q16: Compare Provider, Riverpod, and Bloc.
**A**:
| | Provider | Riverpod | Bloc |
|---|---|---|---|
| BuildContext | Required | Not needed | Required |
| Compile safety | No | Yes | Yes |
| Testability | Good | Excellent | Excellent |
| Learning curve | Low | Medium | High |
| Boilerplate | Low | Medium | High |
| Best for | Small apps | All sizes | Enterprise |

### Q17: What is `context.watch()` vs `context.read()`?
**A**: `watch()` subscribes to changes and triggers rebuild — use in `build()`. `read()` gets the value once without subscribing — use in callbacks (`onPressed`, `onTap`). Using `read` in build = bug (won't update). Using `watch` in callbacks = unnecessary rebuilds.

### Q18: How does Riverpod auto-dispose work?
**A**: When the last widget watching a provider disposes, Riverpod automatically cleans up the provider state and calls `.onDispose()`. Prevents memory leaks. Can be disabled with `keepAlive()` for caching.

---

## 5. Architecture Questions

### Q19: Explain Clean Architecture for Flutter.
**A**: Three layers: **Presentation** (UI + state management), **Domain** (entities, use cases, repo interfaces — pure Dart), **Data** (repo implementations, data sources, DTOs). Dependency rule: outer layers depend on inner. Domain has zero framework dependencies.

### Q20: What is the Repository pattern?
**A**: Abstracts data access behind an interface defined in the domain layer. Implementation in data layer handles actual API/DB calls. Benefits: swap data sources, offline support, testability with mock repos.

### Q21: Feature-first vs Layer-first?
**A**: Feature-first groups code by feature (auth, products), each with its own layers. Scales better, clear boundaries. Layer-first groups by type (models, repos, screens). Simpler but doesn't scale. Feature-first recommended for production apps.

---

## 6. Performance Questions

### Q22: How do you optimize a slow Flutter app?
**A**:
1. Add `const` to all static widgets
2. Split large `build()` into smaller widgets
3. Use `ListView.builder` with `itemExtent`
4. Add `RepaintBoundary` around animated widgets
5. Cache images with `CachedNetworkImage` + `cacheWidth`
6. Move heavy work to `Isolate.run()`
7. Profile with DevTools in `--profile` mode
8. Use `Opacity` widget minimally — prefer color alpha

### Q23: What is RepaintBoundary?
**A**: A widget that isolates its subtree's paint to a separate compositing layer. Only that layer repaints, not siblings or parents. Use for: independently animating content, complex CustomPainters, static content amid changing parents.

### Q24: What is Impeller?
**A**: Flutter's rendering engine (replacing Skia). Pre-compiles all shaders at build time — eliminates first-frame jank. Uses Metal (iOS), Vulkan (Android) natively. Multi-threaded rendering. Default since Flutter 3.16.

---

## 7. System Design for Mobile

### Framework for Mobile System Design

```
1. Requirements Clarification (3-5 min)
   • Features, scale, platforms
   • Offline support? Real-time?

2. High-Level Architecture (5-10 min)
   • Client architecture (layers, features)
   • API design (REST/GraphQL/WebSocket)
   • Data flow diagram

3. Data Model (5-10 min)
   • Domain entities
   • Local storage schema
   • API request/response shapes

4. Key Component Deep Dive (15-20 min)
   • State management choice + justification
   • Caching strategy
   • Offline sync approach
   • Real-time updates
   • Authentication flow

5. Performance & Scale (5-10 min)
   • Image loading / caching
   • List virtualization
   • Background sync
   • Memory management

6. Testing & Deployment (5 min)
   • Test strategy
   • CI/CD pipeline
```

### Example: Design a News App

```
Requirements:
• News feed with infinite scroll, pull-to-refresh
• Article detail with images and text
• Bookmarks (offline available)
• Push notifications for breaking news
• Search
• 1M+ users

Architecture:
┌─────────────────────────────────────────────────────┐
│                  Flutter App                         │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │  Presentation (Riverpod + GoRouter)          │   │
│  │  • FeedPage (infinite scroll)               │   │
│  │  • ArticlePage (offline reading)            │   │
│  │  • BookmarksPage                            │   │
│  │  • SearchPage                               │   │
│  └──────────────────┬──────────────────────────┘   │
│                     │                               │
│  ┌──────────────────▼──────────────────────────┐   │
│  │  Domain (Pure Dart)                          │   │
│  │  • Article, Bookmark, User entities         │   │
│  │  • GetFeed, SearchArticles, ToggleBookmark  │   │
│  │  • Repository interfaces                    │   │
│  └──────────────────┬──────────────────────────┘   │
│                     │                               │
│  ┌──────────────────▼──────────────────────────┐   │
│  │  Data Layer                                  │   │
│  │  Remote: Dio + REST API                     │   │
│  │  Local: Drift (articles cache) + Hive (prefs)│   │
│  │  Strategy: Stale-While-Revalidate           │   │
│  │  Push: Firebase Cloud Messaging             │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  Caching: Stale-while-revalidate                    │
│  Images: CachedNetworkImage + memCacheWidth         │
│  Feed: ListView.builder + pagination (20/page)      │
│  Offline: Bookmarked articles stored in Drift       │
│  Search: Debounced (300ms) + cancel previous        │
└─────────────────────────────────────────────────────┘
```

---

## 8. Behavioral Questions

### Q25: Tell me about a challenging Flutter bug you fixed.
**Structure**: Situation → Task → Action → Result (STAR)

**Example**: "In our e-commerce app, we noticed a memory leak causing the app to slow down after 30 minutes of browsing. I used DevTools Memory tab to take heap snapshots and found that StreamSubscriptions from Firestore were not being cancelled when users navigated away from product pages. I added proper `dispose()` cleanup and created a `DisposableMixin` that all screens now use. Memory usage stabilized and crash reports dropped 80%."

### Q26: How do you decide between trade-offs?
**Example**: "When choosing state management for our 8-person team, I evaluated Provider, Riverpod, and Bloc. Provider was simpler but lacked compile safety. Bloc had great traceability but higher boilerplate. We chose Riverpod because it balanced testability, compile safety, and developer experience. I documented the decision in an ADR and ran a team workshop."

### Q27: How do you handle disagreements with teammates?
**Example**: "A colleague wanted to use GetX for state management. I disagreed due to testability concerns. Instead of dismissing it, I proposed we both build a small feature using our preferred approach. After comparing testability, performance, and code readability, the team collectively chose Riverpod. The exercise strengthened our team decision-making process."

---

## 9. Live Coding Tips

```
┌──────────────────────────────────────────────────┐
│           Live Coding Checklist                   │
│                                                  │
│  1. Clarify the problem before coding            │
│  2. Think aloud — explain your approach          │
│  3. Start with the data model (classes)          │
│  4. Write the structure first, details later     │
│  5. Use const constructors everywhere            │
│  6. Name things clearly                          │
│  7. Handle edge cases (null, empty, error)       │
│  8. Extract widgets into separate classes         │
│  9. Test your code mentally (walk through)       │
│  10. Ask about trade-offs proactively            │
│                                                  │
│  Common Live Coding Tasks:                       │
│  • Build a todo app with state management        │
│  • Create a search with debounce                 │
│  • Implement infinite scroll list                │
│  • Build a form with validation                  │
│  • Parse JSON and display in a list              │
└──────────────────────────────────────────────────┘
```

---

## 10. Quick Revision Sheet

### Flutter Fundamentals
- Everything is a widget → composition over inheritance
- Three trees: Widget, Element, RenderObject
- Build → Layout → Paint → Composite → Rasterize
- `const` = compiled once, never rebuilt
- `Key` = identity for Element reuse

### State Management
- Ephemeral (local) → `setState`
- App state → Provider / Riverpod / Bloc
- `watch` in build, `read` in callbacks
- Riverpod: compile-safe, no BuildContext, auto-dispose
- Bloc: Event → Bloc → State (unidirectional)

### Architecture
- Clean Architecture: Presentation → Domain ← Data
- Domain = pure Dart, no dependencies
- Repository = abstract interface in domain
- Use Case = one business action per class
- DI via get_it or Riverpod providers

### Performance
- `const` everywhere, split widgets, `RepaintBoundary`
- `ListView.builder` + `itemExtent`, `CachedNetworkImage`
- Profile in `--profile` mode, DevTools
- `Isolate.run()` for heavy computation
- Impeller: no shader jank (pre-compiled)

### Navigation
- GoRouter (recommended): `go()` replaces stack, `push()` adds
- ShellRoute for tab navigation
- `redirect` for auth guards
- Deep linking: Android intents + iOS universal links

### Testing
- 70% unit / 20% widget / 10% integration
- `tester.pump()` after `tap()`, `pumpAndSettle()` for animations
- Mockito for dependency mocking
- Golden tests for visual regression

---

[← Previous: Advanced Topics](../14_advanced_topics/14_advanced_topics.md) | [Back to README](../../README.md)
