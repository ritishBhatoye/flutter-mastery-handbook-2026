# Chapter 10 — Performance & Optimization

> **Goal**: Understand Flutter's rendering pipeline and learn production-grade optimization techniques.

---

## Table of Contents

1. [Rendering Pipeline](#1-rendering-pipeline)
2. [Impeller Engine](#2-impeller-engine)
3. [Widget Rebuild Optimization](#3-widget-rebuild-optimization)
4. [RepaintBoundary](#4-repaintboundary)
5. [Lazy Loading & Efficient Lists](#5-lazy-loading--efficient-lists)
6. [Image Optimization](#6-image-optimization)
7. [Memory Profiling](#7-memory-profiling)
8. [CPU Profiling](#8-cpu-profiling)
9. [Shader Warmup](#9-shader-warmup)
10. [Code Size Optimization](#10-code-size-optimization)
11. [Performance Checklist](#11-performance-checklist)
12. [Common Pitfalls](#12-common-pitfalls)
13. [Interview Questions](#13-interview-questions)
14. [Practice Exercises](#14-practice-exercises)
15. [Resources](#15-resources)

---

## 1. Rendering Pipeline

```
┌─────────────────────────────────────────────────────────┐
│              Flutter Rendering Pipeline                  │
│                                                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌───────────┐ │
│  │  Build  │→│  Layout │→│  Paint  │→│ Composite │ │
│  │         │  │         │  │         │  │           │ │
│  │ Widget  │  │Render-  │  │ Canvas  │  │  Layer    │ │
│  │ tree    │  │Object   │  │ draw    │  │  tree     │ │
│  │ diff    │  │ sizing  │  │ commands│  │  combine  │ │
│  └─────────┘  └─────────┘  └─────────┘  └─────┬─────┘ │
│                                                │       │
│                                         ┌──────▼─────┐ │
│                                         │ Rasterize  │ │
│                                         │ (Impeller) │ │
│                                         │  GPU render│ │
│                                         └────────────┘ │
│                                                        │
│  Target: 60 FPS = 16.67ms per frame                    │
│  Target: 120 FPS = 8.33ms per frame                    │
│                                                        │
│  Build + Layout should take < 4ms                      │
│  Paint + Composite should take < 4ms                   │
│  Rasterize should take < 8ms                           │
└─────────────────────────────────────────────────────────┘
```

### Frame Budget

| Target FPS | Frame Budget | Build+Layout | Paint+Raster |
|------------|-------------|-------------|-------------|
| 60 FPS | 16.67 ms | < 8 ms | < 8 ms |
| 120 FPS | 8.33 ms | < 4 ms | < 4 ms |

**Jank** = any frame that takes longer than the budget → visible stutter.

---

## 2. Impeller Engine

Impeller is Flutter's rendering engine (default since Flutter 3.16), replacing Skia.

```
┌──────────────────────────────────────────────┐
│           Impeller vs Skia                    │
├──────────────┬───────────────────────────────┤
│ Feature      │ Skia          │ Impeller      │
├──────────────┼───────────────┼───────────────┤
│ Shader comp. │ Runtime (jank)│ Build-time    │
│ First frame  │ Slow (shader  │ Fast (pre-    │
│              │  compilation) │  compiled)    │
│ Consistency  │ Varies        │ Predictable   │
│ Metal (iOS)  │ Via bridge    │ Native        │
│ Vulkan (And) │ Via bridge    │ Native        │
│ Multi-thread │ Limited       │ Yes           │
└──────────────┴───────────────┴───────────────┘
```

Key benefit: **No shader compilation jank** — all shaders are pre-compiled at build time.

---

## 3. Widget Rebuild Optimization

### Use `const` Constructors

```dart
// ❌ Rebuilds every frame
child: Text('Hello')

// ✅ Compile-time constant — never rebuilt
child: const Text('Hello')

// ✅ Use const for entire subtrees
const _Header(),                  // Entire widget is const
const SizedBox(height: 16),       // Spacers as const
const Divider(),                  // Decorators as const
```

### Split Widgets

```dart
// ❌ Bad — entire build() re-runs when count changes
class BadWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveHeader(),        // Rebuilds unnecessarily
        Text('$_count'),          // Only this needs to change
        ExpensiveFooter(),        // Rebuilds unnecessarily
      ],
    );
  }
}

// ✅ Good — extract unchanging parts
class GoodWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ExpensiveHeader(),  // const — won't rebuild
        CounterDisplay(count: _count),
        const ExpensiveFooter(),  // const — won't rebuild
      ],
    );
  }
}
```

### Avoid Rebuilding in Loops

```dart
// ❌ Creating new TextStyle on every build
Text('Hello', style: TextStyle(fontSize: 16, color: Colors.black))

// ✅ Cache reusable objects
static const _titleStyle = TextStyle(fontSize: 16, color: Colors.black);
Text('Hello', style: _titleStyle)
```

---

## 4. RepaintBoundary

Isolates a subtree's paint operations. The subtree paints to its own layer and is cached.

```dart
// Wrap frequently-animating widgets to prevent repainting siblings
RepaintBoundary(
  child: AnimatedWidget(), // Only this repaints, not the parent
)
```

### When to Use

```
✅ Use RepaintBoundary when:
  • Widget animates independently (progress bar, clock)
  • Complex widget rarely changes (static chart)
  • Expensive CustomPainter

❌ Don't use when:
  • Widget always changes with parent (adds layer overhead)
  • Simple widgets (overhead > benefit)
```

### Debugging Repaints

```bash
# Show repaint rainbow — each paint gets a new color
flutter run --debug --track-widget-creation
```

```dart
// In code
debugRepaintRainbowEnabled = true;
```

---

## 5. Lazy Loading & Efficient Lists

### ListView.builder vs ListView

```dart
// ❌ ListView — builds ALL children upfront
ListView(
  children: List.generate(10000, (i) => ListTile(title: Text('$i'))),
) // Builds 10,000 widgets!

// ✅ ListView.builder — builds only visible + buffer
ListView.builder(
  itemCount: 10000,
  itemBuilder: (context, index) {
    return ListTile(title: Text('$index'));
  },
) // Builds only ~15 widgets at a time
```

### itemExtent for Uniform Lists

```dart
// If all items have the same height, set itemExtent
ListView.builder(
  itemExtent: 72, // Known fixed height
  itemCount: 10000,
  itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
)
// Flutter can skip measuring each child — massive perf win for long lists
```

### Pagination / Infinite Scroll

```dart
class InfiniteList extends StatefulWidget {
  @override
  _InfiniteListState createState() => _InfiniteListState();
}

class _InfiniteListState extends State<InfiniteList> {
  final _scrollController = ScrollController();
  List<Item> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_loading) return;
    _loading = true;
    final newItems = await api.getItems(page: _items.length ~/ 20);
    setState(() {
      _items.addAll(newItems);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _items.length) {
          return ItemCard(item: _items[index]);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 6. Image Optimization

```dart
// 1. Specify cacheWidth/cacheHeight to decode at display size
Image.network(
  url,
  cacheWidth: 200,    // Decode at 200px, not original 4000px
  cacheHeight: 200,
)

// 2. Use CachedNetworkImage for caching
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 200,
  placeholder: (_, __) => const Shimmer(),
)

// 3. Precache images
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(AssetImage('assets/hero.jpg'), context);
}

// 4. Use WebP format (smaller than PNG/JPEG)
// 5. Use ResizeImage for asset images
Image(image: ResizeImage(AssetImage('large.png'), width: 200))
```

---

## 7. Memory Profiling

### Using DevTools Memory Tab

```bash
# Launch DevTools
dart devtools
```

Key metrics:
- **Used Heap**: Active Dart objects
- **External**: Native memory (images, platform allocations)
- **RSS**: Total process memory

### Common Memory Leaks

```dart
// ❌ Leak: StreamSubscription not cancelled
class _LeakyState extends State<LeakyWidget> {
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = someStream.listen((data) {
      setState(() { /* update UI */ });
    });
  }

  // 💥 Missing dispose!
}

// ✅ Fixed
@override
void dispose() {
  _sub.cancel();
  super.dispose();
}
```

### Leak Detection

```dart
// Enable leak tracking in tests
testWidgets('no memory leaks', (tester) async {
  await tester.pumpWidget(MyWidget());
  // DevTools will flag undisposed controllers
});
```

---

## 8. CPU Profiling

### DevTools CPU Profiler

1. Run in profile mode: `flutter run --profile`
2. Open DevTools → Performance tab
3. Record a trace → analyze flame chart

### What to Look For

```
┌─────────────────────────────────────────┐
│  🔴 Red flags in flame chart:          │
│                                         │
│  • Long build() calls (> 4ms)           │
│  • Layout taking > 4ms                  │
│  • JSON parsing on main isolate         │
│  • Image decoding blocking UI           │
│  • Excessive garbage collection         │
└─────────────────────────────────────────┘
```

### Move Heavy Work Off Main Isolate

```dart
// Use Isolate.run for CPU-intensive work
final parsed = await Isolate.run(() {
  return jsonDecode(hugeJsonString);
});

// Use compute for Flutter apps
final users = await compute(parseUsers, jsonString);
```

---

## 9. Shader Warmup

With Impeller (2026 default), shader warmup is largely unnecessary. For Skia:

```dart
// Capture shaders during testing
// flutter run --profile --cache-sksl --purge-persistent-cache
// Then bundle: flutter build apk --bundle-sksl-path flutter_01.sksl.json
```

Impeller pre-compiles all shaders at build time → no runtime compilation → no jank.

---

## 10. Code Size Optimization

```bash
# Analyze app size
flutter build apk --analyze-size
flutter build ios --analyze-size

# Check what's in your binary
# Output: app_size_analysis.json → open in DevTools
```

### Optimization Techniques

| Technique | Savings |
|-----------|---------|
| `--split-debug-info` | 30-40% debug info removed |
| `--obfuscate` | Smaller symbol table |
| `--tree-shake-icons` | Remove unused Material icons |
| Remove unused packages | Varies |
| Deferred components | Split large features |
| WebP images | 25-35% smaller than PNG |

```bash
flutter build apk --release \
  --split-debug-info=build/debug-info \
  --obfuscate \
  --tree-shake-icons
```

### Deferred Components (Code Splitting)

```dart
// Load features on demand
import 'package:my_app/heavy_feature.dart' deferred as heavy;

Future<void> loadFeature() async {
  await heavy.loadLibrary();
  // Now can use heavy.HeavyWidget()
}
```

---

## 11. Performance Checklist

```
□ Use const constructors everywhere possible
□ Use ListView.builder for long lists
□ Set itemExtent for uniform-height lists
□ Specify cacheWidth/cacheHeight for images
□ Add RepaintBoundary around animated widgets
□ Move JSON parsing to Isolate.run
□ Dispose all controllers and subscriptions
□ Split huge build() into smaller widgets
□ Cache TextStyle and other reusable objects
□ Profile with DevTools in --profile mode
□ Run --analyze-size and remove unused code
□ Use --split-debug-info and --obfuscate for release
□ Enable --tree-shake-icons
□ Use WebP format for images
□ Avoid setState on the root widget
```

---

## 12. Common Pitfalls

### ❌ Profiling in Debug Mode
Debug mode includes JIT overhead. Always profile in `--profile` mode.

### ❌ Using `Opacity` Widget Instead of Color Opacity
```dart
// Bad — creates a new layer
Opacity(opacity: 0.5, child: Container(color: Colors.red))

// Good — uses color's alpha channel directly
Container(color: Colors.red.withOpacity(0.5))
```

### ❌ Building Huge Widget Trees in Single Build Method
Extract sub-widgets into separate `StatelessWidget` classes for better granularity.

---

## 13. Interview Questions

### Q1: Explain Flutter's rendering pipeline.
**A**: Build (diff widgets, create/update Elements) → Layout (constraints down, sizes up via RenderObject.performLayout) → Paint (Canvas draw commands via RenderObject.paint) → Composite (Layer tree assembly) → Rasterize (GPU via Impeller). Target: 16ms per frame at 60 FPS.

### Q2: What is RepaintBoundary?
**A**: A widget that isolates its subtree's paint operations into a separate compositing layer. When the subtree needs to repaint, only that layer is re-rendered, not sibling or parent layers. Use for independently animating widgets to prevent unnecessary repainting.

### Q3: How do you optimize ListView performance?
**A**: (1) Use `ListView.builder` not `ListView` for lazy building. (2) Set `itemExtent` for uniform heights. (3) Use `const` widgets for static items. (4) Cache images with `CachedNetworkImage`. (5) Add `key` for stable item identity. (6) Use `addAutomaticKeepAlives: false` if keep-alive isn't needed.

### Q4: What is Impeller and why does it matter?
**A**: Impeller is Flutter's rendering backend that pre-compiles all shaders at build time using Metal (iOS) and Vulkan (Android). This eliminates shader compilation jank — the most common source of first-frame stutter in Skia. It also uses multi-threaded rendering for better performance.

### Q5: How do you detect memory leaks?
**A**: Use DevTools Memory tab to take heap snapshots. Look for objects that should be garbage collected but aren't (retained by listeners, streams, closures). Common causes: undisposed controllers, uncancelled subscriptions, closures capturing `this`. Enable leak tracking in tests.

---

## 14. Practice Exercises

### Exercise 1: Optimize a Slow List
Take a `ListView` with 10,000 items and apply all optimizations: builder, itemExtent, const widgets, cached images. Measure before/after in DevTools.

### Exercise 2: Repaint Analysis
Use `debugRepaintRainbowEnabled` to identify unnecessary repaints in a complex UI. Add `RepaintBoundary` and measure improvement.

### Exercise 3: App Size Reduction
Run `--analyze-size` on a project. Remove unused packages, tree-shake icons, and enable obfuscation. Target 20% size reduction.

---

## 15. Resources

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf)
- [DevTools Performance View](https://docs.flutter.dev/tools/devtools/performance)
- [Impeller Rendering Engine](https://github.com/flutter/flutter/wiki/Impeller)
- [App Size Tool](https://docs.flutter.dev/tools/devtools/app-size)

---

[← Previous: Platform Integration](../09_platform_integration/09_platform_integration.md) | [Next: Testing →](../11_testing/11_testing.md) | [Back to README](../../README.md)
