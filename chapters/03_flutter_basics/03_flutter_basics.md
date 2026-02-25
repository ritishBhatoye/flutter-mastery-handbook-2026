# Chapter 03 — Flutter Basics

> **Goal**: Master Flutter's core widget system, layout model, rendering process, and essential UI patterns.

---

## Table of Contents

1. [Widget Fundamentals](#1-widget-fundamentals)
2. [StatelessWidget vs StatefulWidget](#2-statelesswidget-vs-statefulwidget)
3. [Widget Lifecycle](#3-widget-lifecycle)
4. [BuildContext and the Widget Tree](#4-buildcontext-and-the-widget-tree)
5. [The Three Trees](#5-the-three-trees)
6. [Keys](#6-keys)
7. [Layout System](#7-layout-system)
8. [Common Layout Widgets](#8-common-layout-widgets)
9. [Slivers](#9-slivers)
10. [Theming & Styling](#10-theming--styling)
11. [Asset & Image Management](#11-asset--image-management)
12. [Responsive Design](#12-responsive-design)
13. [Forms & Input](#13-forms--input)
14. [Common Pitfalls](#14-common-pitfalls)
15. [Interview Questions](#15-interview-questions)
16. [Practice Exercises](#16-practice-exercises)
17. [Resources](#17-resources)

---

## 1. Widget Fundamentals

> **"Everything in Flutter is a widget."**

A widget is an **immutable description** of part of the UI. Widgets are lightweight configuration objects — they don't draw or lay out themselves. The framework handles that.

### Widget Categories

```
┌──────────────────────────────────────────────┐
│              Flutter Widgets                  │
├──────────────┬───────────────────────────────┤
│  Structural  │  Visual / Painting            │
│  ┌─────────┐ │  ┌───────────┐  ┌──────────┐ │
│  │Container│ │  │   Text    │  │  Image   │ │
│  │ Row     │ │  │   Icon    │  │  Canvas  │ │
│  │ Column  │ │  │   Card    │  │ CustomPaint│
│  │ Stack   │ │  │   Button  │  │          │ │
│  │ Padding │ │  │  TextField│  │          │ │
│  └─────────┘ │  └───────────┘  └──────────┘ │
├──────────────┼───────────────────────────────┤
│  Scrolling   │  Interactive                  │
│  ┌─────────┐ │  ┌───────────┐  ┌──────────┐ │
│  │ListView │ │  │GestureDetec│ │ InkWell  │ │
│  │GridView │ │  │ Dismissible│ │ Draggable│ │
│  │Sliver*  │ │  │ Slider    │ │ Switch   │ │
│  │ScrollView││  │ Checkbox  │ │          │ │
│  └─────────┘ │  └───────────┘  └──────────┘ │
└──────────────┴───────────────────────────────┘
```

### Composition Over Inheritance

Flutter prefers **composition** — building complex UIs by combining simpler widgets:

```dart
// Flutter approach: compose small widgets
class ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String avatarUrl;

  const ProfileCard({
    super.key,
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(avatarUrl),
        ),
        title: Text(name),
        subtitle: Text(role),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
```

---

## 2. StatelessWidget vs StatefulWidget

### StatelessWidget

No mutable state. Output depends only on constructor parameters.

```dart
class Greeting extends StatelessWidget {
  final String name;
  const Greeting({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name!');
  }
}
```

### StatefulWidget

Has mutable state that can change during the widget's lifetime.

```dart
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Count: $_count', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => setState(() => _count++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

### When to Use Which?

```
Use StatelessWidget when:
  ✅ Widget depends only on its constructor arguments
  ✅ No internal state changes
  ✅ Pure display widgets (labels, icons, cards)
  ✅ Widgets that depend on InheritedWidget data

Use StatefulWidget when:
  ✅ Widget needs to track mutable data
  ✅ Animations (AnimationController requires State mixin)
  ✅ Form input handling
  ✅ Listening to streams or subscriptions
```

---

## 3. Widget Lifecycle

### StatefulWidget Lifecycle

```
                    ┌─────────────┐
                    │ createState  │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  initState   │  ← Called once
                    └──────┬──────┘
                           │
                    ┌──────▼──────────────┐
               ┌───▶│  didChangeDependencies│ ← InheritedWidget changed
               │    └──────┬──────────────┘
               │           │
               │    ┌──────▼──────┐
               │    │    build     │  ← Returns widget tree
               │    └──────┬──────┘
               │           │
               │    ┌──────▼─────────────────┐
               │    │ didUpdateWidget          │ ← Parent rebuilt with new config
               │    └──────┬─────────────────┘
               │           │
               │    ┌──────▼──────┐
               └────│  setState    │  ← Triggers rebuild
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  deactivate  │  ← Removed from tree (may re-insert)
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   dispose    │  ← Permanently removed. Clean up!
                    └─────────────┘
```

### Lifecycle Methods in Practice

```dart
class LifecycleWidget extends StatefulWidget {
  const LifecycleWidget({super.key});

  @override
  State<LifecycleWidget> createState() => _LifecycleWidgetState();
}

class _LifecycleWidgetState extends State<LifecycleWidget>
    with WidgetsBindingObserver {

  late final TextEditingController _controller;
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    // ✅ Initialize controllers, start subscriptions
    _controller = TextEditingController();
    _subscription = myStream.listen(_onData);
    WidgetsBinding.instance.addObserver(this);
    debugPrint('initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Called when InheritedWidget dependency changes
    // Safe to call: Theme.of(context), MediaQuery.of(context), etc.
    debugPrint('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant LifecycleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Called when parent rebuilds with same runtimeType but new config
    debugPrint('didUpdateWidget');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App lifecycle: inactive, paused, resumed, detached, hidden
    debugPrint('App lifecycle: $state');
  }

  @override
  void dispose() {
    // ✅ ALWAYS clean up: controllers, subscriptions, observers
    _controller.dispose();
    _subscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('dispose');
    super.dispose();
  }

  void _onData(dynamic data) {
    if (mounted) {
      setState(() { /* update state */ });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build');
    return const Placeholder();
  }
}
```

---

## 4. BuildContext and the Widget Tree

### What is BuildContext?

`BuildContext` is a handle to the **location** of a widget in the Element Tree. It's used to:
- Look up `InheritedWidget` data (`Theme.of(context)`, `MediaQuery.of(context)`)
- Navigate (`Navigator.of(context)`)
- Show overlays (`showDialog`, `ScaffoldMessenger.of(context)`)

```dart
@override
Widget build(BuildContext context) {
  // Access theme
  final theme = Theme.of(context);

  // Access screen size
  final size = MediaQuery.sizeOf(context);

  // Access scaffold
  ScaffoldMessenger.of(context).showSnackBar(...);

  // Navigate
  Navigator.of(context).push(...);

  return Container();
}
```

### ⚠️ Context Gotchas

```dart
// ❌ WRONG: Using context of a widget that doesn't have Scaffold as ancestor
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ElevatedButton(
      onPressed: () {
        // This context is from the widget ABOVE Scaffold
        // ScaffoldMessenger.of(context).showSnackBar(...); // May fail!
      },
      child: const Text('Show SnackBar'),
    ),
  );
}

// ✅ RIGHT: Use Builder to get context below Scaffold
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Builder(
      builder: (scaffoldContext) {
        return ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
              const SnackBar(content: Text('Hello!')),
            );
          },
          child: const Text('Show SnackBar'),
        );
      },
    ),
  );
}
```

---

## 5. The Three Trees

```
Widget Tree                Element Tree              RenderObject Tree
(Configuration)            (Lifecycle)               (Layout + Paint)

MaterialApp                MaterialAppElement         ─
  └── Scaffold             └── ScaffoldElement       └── RenderFlex
        ├── AppBar               ├── AppBarElement         ├── RenderAppBar
        └── Column               └── ColumnElement         └── RenderFlex
              ├── Text                 ├── TextElement            ├── RenderParagraph
              └── Button               └── ButtonElement          └── RenderButton
```

### How Rebuilds Work

1. `setState()` marks the Element as dirty
2. Framework calls `build()` on the dirty element
3. Framework **diffs** old widgets vs new widgets
4. **Same type + same key?** → Update existing Element → Update RenderObject
5. **Different type or key?** → Unmount old Element, create new one

> 💡 This is why widgets are cheap to create — the Element tree persists and only updates what changed.

---

## 6. Keys

Keys tell Flutter how to match widgets across rebuilds.

```dart
// Without key — Flutter matches by position (can cause bugs)
Column(
  children: [
    if (!deleted) TextField(controller: _ctrl1), // ← Position 0
    TextField(controller: _ctrl2),                // ← Position 0 after delete!
  ],
);

// With key — Flutter matches by key (correct behavior)
Column(
  children: [
    if (!deleted) TextField(key: const ValueKey('field1'), controller: _ctrl1),
    TextField(key: const ValueKey('field2'), controller: _ctrl2),
  ],
);
```

### Key Types

| Key Type | Use When |
|----------|----------|
| `ValueKey` | Identity based on a value (ID, string) |
| `ObjectKey` | Identity based on object reference |
| `UniqueKey` | Always unique (forces recreation) |
| `GlobalKey` | Need to access State from elsewhere (use sparingly) |

---

## 7. Layout System

### Constraints-Based Layout

Flutter uses a **constraints-down, sizes-up** model:

```
┌─────────────────────────────────────────────────┐
│                Layout Protocol                   │
│                                                  │
│  1. Parent passes CONSTRAINTS down               │
│     (min/max width, min/max height)              │
│                                                  │
│  2. Child chooses its SIZE within constraints     │
│                                                  │
│  3. Parent decides child's POSITION               │
│                                                  │
│  ┌──────────┐  constraints  ┌──────────┐         │
│  │  Parent   │ ────────────▶│  Child   │         │
│  │          │ ◀────────────│          │         │
│  │          │    size       │          │         │
│  └──────────┘               └──────────┘         │
│                                                  │
└─────────────────────────────────────────────────┘
```

### BoxConstraints

```dart
// Tight constraints — exact size
BoxConstraints.tight(Size(200, 100))
// minWidth=200, maxWidth=200, minHeight=100, maxHeight=100

// Loose constraints — up to a maximum
BoxConstraints.loose(Size(200, 100))
// minWidth=0, maxWidth=200, minHeight=0, maxHeight=100

// Expanding — fill parent
BoxConstraints.expand()
// minWidth=∞, maxWidth=∞, minHeight=∞, maxHeight=∞

// Custom
BoxConstraints(minWidth: 100, maxWidth: 300, minHeight: 50, maxHeight: 200)
```

### Common Layout Rules

```
┌──────────────────────────────────────────────────────┐
│  "Constraints go down. Sizes go up.                  │
│   Parents set positions."                            │
│                                                      │
│  Rule 1: A widget gets constraints from its parent   │
│  Rule 2: A widget picks its own size within those    │
│  Rule 3: A widget positions each child one by one    │
│  Rule 4: A widget reports its size to its parent     │
│                                                      │
│  KEY INSIGHT:                                        │
│  A widget's size is determined by its parent's       │
│  constraints AND the widget's own preferences.       │
│                                                      │
│  Container of width: 200 inside a tight-300          │
│  constraint? → Container becomes 300!                │
└──────────────────────────────────────────────────────┘
```

---

## 8. Common Layout Widgets

### Row & Column

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,  // ← Horizontal
  crossAxisAlignment: CrossAxisAlignment.center,      // ← Vertical
  children: [
    const Icon(Icons.star),
    const Text('Rating'),
    const Text('4.5'),
  ],
)

Column(
  mainAxisAlignment: MainAxisAlignment.center,        // ← Vertical
  crossAxisAlignment: CrossAxisAlignment.stretch,     // ← Horizontal
  children: [
    const Text('Title'),
    const SizedBox(height: 8),
    const Text('Subtitle'),
  ],
)
```

### Expanded & Flexible

```dart
Row(
  children: [
    // Takes remaining space, flex:2
    Expanded(
      flex: 2,
      child: Container(color: Colors.red, height: 50),
    ),
    // Takes remaining space, flex:1
    Expanded(
      flex: 1,
      child: Container(color: Colors.blue, height: 50),
    ),
    // Fixed size
    const SizedBox(width: 50, height: 50),
  ],
)

// Flexible with FlexFit.loose — child can be smaller than allocated space
Flexible(
  fit: FlexFit.loose,
  child: Text('May be smaller'),
)
```

### Stack & Positioned

```dart
Stack(
  children: [
    // Background
    Container(width: 300, height: 200, color: Colors.grey[200]),

    // Positioned overlay
    Positioned(
      top: 10,
      right: 10,
      child: Chip(label: Text('NEW')),
    ),

    // Centered overlay
    const Center(
      child: Text('Centered Text'),
    ),
  ],
)
```

### ListView

```dart
// Static list (for short lists only)
ListView(
  children: [
    ListTile(title: Text('Item 1')),
    ListTile(title: Text('Item 2')),
  ],
)

// Builder (lazy — use for long/infinite lists)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)

// Separated
ListView.separated(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(title: Text(items[index])),
  separatorBuilder: (context, index) => const Divider(),
)
```

### GridView

```dart
// Fixed column count
GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
  children: products.map((p) => ProductCard(product: p)).toList(),
)

// Lazy builder
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    childAspectRatio: 0.75,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

### Wrap

```dart
// Tags / chips that wrap to next line
Wrap(
  spacing: 8,
  runSpacing: 4,
  children: tags.map((tag) => Chip(label: Text(tag))).toList(),
)
```

---

## 9. Slivers

Slivers are scrollable areas that produce visual effects as the user scrolls.

```dart
CustomScrollView(
  slivers: [
    // Collapsible app bar
    SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('My App'),
        background: Image.network('https://...', fit: BoxFit.cover),
      ),
    ),

    // Sliver list
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text('Item $index')),
        childCount: 50,
      ),
    ),

    // Sliver grid
    SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => Card(child: Center(child: Text('Grid $index'))),
        childCount: 20,
      ),
    ),

    // Sliver padding
    SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Text('Footer'),
      ),
    ),
  ],
)
```

---

## 10. Theming & Styling

### Material 3 Theming

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.deepPurple,
    brightness: Brightness.light,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
    ),
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
  themeMode: ThemeMode.system,
)
```

### Using Theme Data

```dart
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

Text(
  'Hello',
  style: theme.textTheme.headlineMedium?.copyWith(
    color: colorScheme.primary,
    fontWeight: FontWeight.w600,
  ),
);

Container(
  decoration: BoxDecoration(
    color: colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: colorScheme.outlineVariant),
  ),
);
```

---

## 11. Asset & Image Management

### Declaring Assets

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/

  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

### Loading Images

```dart
// Asset image
Image.asset('assets/images/logo.png', width: 120)

// Network image
Image.network(
  'https://example.com/image.jpg',
  fit: BoxFit.cover,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return CircularProgressIndicator(
      value: progress.expectedTotalBytes != null
          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
          : null,
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.broken_image, size: 48);
  },
)

// Cached (with cached_network_image package)
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

---

## 12. Responsive Design

```dart
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return const DesktopLayout();
        } else if (constraints.maxWidth >= 600) {
          return const TabletLayout();
        } else {
          return const MobileLayout();
        }
      },
    );
  }
}

// Using MediaQuery
final screenWidth = MediaQuery.sizeOf(context).width;
final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
final padding = MediaQuery.paddingOf(context); // Safe areas
final textScale = MediaQuery.textScaleFactorOf(context);
```

---

## 13. Forms & Input

```dart
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Process login
      debugPrint('Email: ${_emailController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              if (!value.contains('@')) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 8) return 'Min 8 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Sign In'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 14. Common Pitfalls

### ❌ Nesting Scrollables Without Proper Constraints
```dart
// Bad — ListView inside Column without bounds
Column(
  children: [
    ListView(...), // 💥 Unbounded height error
  ],
)

// Good — Use Expanded or ShrinkWrap
Column(
  children: [
    Expanded(child: ListView(...)),
    // or: ListView(shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
  ],
)
```

### ❌ Using setState After Dispose
```dart
// Bad
Future.delayed(Duration(seconds: 2), () {
  setState(() { ... }); // 💥 May crash if widget disposed
});

// Good — check mounted
Future.delayed(Duration(seconds: 2), () {
  if (mounted) setState(() { ... });
});
```

### ❌ Not Disposing Controllers
```dart
// Always dispose TextEditingController, AnimationController,
// ScrollController, FocusNode, StreamSubscription
@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  super.dispose();
}
```

### ❌ Using MediaQuery When LayoutBuilder Works
```dart
// MediaQuery causes rebuild on ANY media change (keyboard, rotation, etc.)
// LayoutBuilder only rebuilds when parent constraints change
```

---

## 15. Interview Questions

### Q1: What is the difference between StatelessWidget and StatefulWidget?
**A**: StatelessWidget is immutable — once built, it never changes. Its `build()` output depends solely on constructor parameters. StatefulWidget has a companion `State` object that can hold mutable data. When `setState()` is called, the framework rebuilds the widget. StatefulWidget is needed for animations, form inputs, or any UI that changes over time.

### Q2: Explain the three trees in Flutter.
**A**: Widget Tree (cheap, immutable configs), Element Tree (long-lived lifecycle managers that bridge widgets and render objects), RenderObject Tree (expensive objects that handle layout via `performLayout()` and painting via `paint()`). When a widget rebuilds, Flutter diffs widgets, updates Elements, and only modifies RenderObjects when the actual visual output changes.

### Q3: What is BuildContext?
**A**: A handle to an Element's position in the Element Tree. Used to look up ancestors (`Theme.of(context)`, `Navigator.of(context)`). Each widget's `build` method receives the BuildContext of its own Element. Important: the context is only valid during and after `build()`; don't use the context of a disposed widget.

### Q4: When should you use Keys?
**A**: When Flutter reorders, adds, or removes children of the same type. Without keys, Flutter matches by position, which can cause state to stick to the wrong widget (e.g., checkboxes in a reorderable list). Types: `ValueKey` (by value), `ObjectKey` (by reference), `UniqueKey` (always different), `GlobalKey` (access State across tree).

### Q5: Explain Flutter's layout algorithm.
**A**: Constraints go down, sizes go up, parent sets position. Parent passes `BoxConstraints` (min/max width & height) to child. Child determines its own size within those constraints. Parent then positions the child. This is a single-pass O(N) algorithm (no negotiation). `RenderBox.performLayout()` implements this.

### Q6: What is the difference between `Expanded` and `Flexible`?
**A**: Both distribute remaining space in a `Row`/`Column`. `Expanded` forces the child to fill all allocated space (`FlexFit.tight`). `Flexible` allows the child to be smaller than allocated space (`FlexFit.loose`). Both accept a `flex` factor for proportional sizing.

### Q7: What are Slivers?
**A**: Slivers are scrollable regions within a `CustomScrollView`. Each sliver produces a "sliver geometry" based on its scroll offset. `SliverList`, `SliverGrid`, `SliverAppBar` are common slivers. They enable scroll effects impossible with `ListView`/`GridView` (e.g., collapsing headers, parallax, mixed layouts).

### Q8: How does Flutter handle responsive design?
**A**: Use `LayoutBuilder` for constraint-based breakpoints, `MediaQuery` for screen info (size, padding, text scale), `Flex` + `Expanded` for proportional layouts, `FractionallySizedBox` for percentage sizing, and `ConstrainedBox` for limits. For adaptive widgets, `Scaffold` adapts navigation, and `PlatformAdaptiveWidget` pattern handles platform-specific UI.

---

## 16. Practice Exercises

### Exercise 1: Profile Card
Build a profile card with avatar, name, title, and stats (followers, following, posts) using `Row`, `Column`, `CircleAvatar`, and `Card`.

### Exercise 2: Product Grid
Create a 2-column product grid with image, title, price, and rating using `GridView.builder`. Add a search bar at the top.

### Exercise 3: Custom ScrollView
Build a screen with a `SliverAppBar` (collapsible image), `SliverList` (text items), and `SliverGrid` (image grid) in one `CustomScrollView`.

### Exercise 4: Responsive Layout
Create a layout that shows 1 column on mobile, 2 columns on tablet, and 3 columns + sidebar on desktop using `LayoutBuilder`.

---

## 17. Resources

- [Flutter Layout Guide](https://docs.flutter.dev/development/ui/layout)
- [Understanding Constraints](https://docs.flutter.dev/development/ui/layout/constraints)
- [Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [Slivers Explained](https://docs.flutter.dev/development/ui/advanced/slivers)
- [Material 3 Design](https://m3.material.io/)

---

[← Previous: Dart Deep Dive](../02_dart_deep_dive/02_dart_deep_dive.md) | [Next: State Management →](../04_state_management/04_state_management.md) | [Back to README](../../README.md)
