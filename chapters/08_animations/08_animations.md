# Chapter 08 — Animations

> **Goal**: Master Flutter's animation system — from simple implicit animations to complex explicit, physics-based, and custom animations.

---

## Table of Contents

1. [Animation Fundamentals](#1-animation-fundamentals)
2. [Implicit Animations](#2-implicit-animations)
3. [Explicit Animations](#3-explicit-animations)
4. [Physics-Based Animations](#4-physics-based-animations)
5. [Hero Animations](#5-hero-animations)
6. [Staggered Animations](#6-staggered-animations)
7. [Page Transitions](#7-page-transitions)
8. [Lottie & Rive](#8-lottie--rive)
9. [Custom Painter With Animation](#9-custom-painter-with-animation)
10. [Common Pitfalls](#10-common-pitfalls)
11. [Interview Questions](#11-interview-questions)
12. [Practice Exercises](#12-practice-exercises)
13. [Resources](#13-resources)

---

## 1. Animation Fundamentals

```
┌──────────────────────────────────────────────────┐
│         Flutter Animation Architecture           │
│                                                  │
│  ┌──────────────┐   drives   ┌──────────────┐   │
│  │ Animation-   │ ─────────▶ │  Animation   │   │
│  │ Controller   │            │  <double>    │   │
│  └──────────────┘            └──────┬───────┘   │
│   • Duration                        │           │
│   • vsync (Ticker)           ┌──────▼───────┐   │
│   • forward/reverse          │    Tween     │   │
│                              │  begin → end │   │
│                              └──────┬───────┘   │
│                                     │           │
│                              ┌──────▼───────┐   │
│                              │    Curve     │   │
│                              │  easeInOut   │   │
│                              │  bounceOut   │   │
│                              └──────┬───────┘   │
│                                     │           │
│                              ┌──────▼───────┐   │
│                              │   Widget     │   │
│                              │  (rebuilds)  │   │
│                              └──────────────┘   │
└──────────────────────────────────────────────────┘
```

### Decision Tree

```
Need animation? →
  ├── Simple property change? → Implicit (AnimatedFoo)
  ├── Need control (play/pause/repeat)? → Explicit (AnimationController)
  ├── Natural motion (spring, friction)? → Physics-based
  ├── Shared element between screens? → Hero
  └── Complex sequence? → Staggered / TweenSequence
```

---

## 2. Implicit Animations

Zero boilerplate — just change a value and Flutter animates the transition.

```dart
// AnimatedContainer — animates all Container properties
class AnimatedBox extends StatefulWidget {
  @override
  State<AnimatedBox> createState() => _AnimatedBoxState();
}

class _AnimatedBoxState extends State<AnimatedBox> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        width: _expanded ? 300 : 100,
        height: _expanded ? 300 : 100,
        decoration: BoxDecoration(
          color: _expanded ? Colors.blue : Colors.red,
          borderRadius: BorderRadius.circular(_expanded ? 24 : 8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: _expanded ? 20 : 5,
              offset: Offset(0, _expanded ? 10 : 2),
            ),
          ],
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: Colors.white,
              fontSize: _expanded ? 24 : 14,
              fontWeight: FontWeight.bold,
            ),
            child: const Text('Tap me'),
          ),
        ),
      ),
    );
  }
}
```

### Common Implicit Animation Widgets

| Widget | Animates |
|--------|----------|
| `AnimatedContainer` | Size, color, padding, decoration, constraints |
| `AnimatedOpacity` | Opacity |
| `AnimatedPadding` | Padding |
| `AnimatedAlign` | Alignment |
| `AnimatedPositioned` | Position in Stack |
| `AnimatedDefaultTextStyle` | Text style |
| `AnimatedSwitcher` | Widget transitions (fade, scale) |
| `AnimatedCrossFade` | Cross-fade between two widgets |
| `AnimatedSize` | Size changes |
| `AnimatedSlide` | Offset-based sliding |
| `AnimatedRotation` | Rotation |
| `AnimatedScale` | Scale |
| `TweenAnimationBuilder` | Custom tween (most flexible implicit) |

### AnimatedSwitcher

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, animation) {
    return ScaleTransition(scale: animation, child: child);
  },
  child: Text(
    '$_count',
    key: ValueKey<int>(_count), // KEY IS REQUIRED for switch detection
    style: const TextStyle(fontSize: 48),
  ),
)
```

### TweenAnimationBuilder

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: _progress),
  duration: const Duration(milliseconds: 800),
  curve: Curves.easeInOut,
  builder: (context, value, child) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 6,
          ),
        ),
        Text('${(value * 100).toInt()}%'),
      ],
    );
  },
)
```

---

## 3. Explicit Animations

Full control over animation playback, direction, and status.

```dart
class PulseWidget extends StatefulWidget {
  const PulseWidget({super.key});
  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 48),
      ),
    );
  }
}
```

### AnimationController Methods

```dart
_controller.forward();        // Play forward (0 → 1)
_controller.reverse();         // Play backward (1 → 0)
_controller.repeat();          // Loop forever
_controller.repeat(reverse: true); // Ping-pong
_controller.stop();            // Pause
_controller.reset();           // Jump to 0
_controller.animateTo(0.5);   // Animate to specific value
_controller.value = 0.7;      // Jump to value (no animation)
```

### Built-in Transition Widgets

```dart
// These wrap AnimatedBuilder with common transforms
FadeTransition(opacity: _animation, child: widget);
ScaleTransition(scale: _animation, child: widget);
SlideTransition(position: _offsetAnimation, child: widget);
RotationTransition(turns: _animation, child: widget);
SizeTransition(sizeFactor: _animation, child: widget);
DecoratedBoxTransition(decoration: _decorationAnimation, child: widget);
```

---

## 4. Physics-Based Animations

Natural-feeling motion using physics simulations.

```dart
class SpringWidget extends StatefulWidget {
  @override
  State<SpringWidget> createState() => _SpringWidgetState();
}

class _SpringWidgetState extends State<SpringWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Spring simulation
    const spring = SpringDescription(
      mass: 1,
      stiffness: 100,
      damping: 10,
    );

    final simulation = SpringSimulation(spring, 0, 1, 0); // start, end, velocity

    _controller.animateWith(simulation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _controller.value,
          child: child,
        );
      },
      child: const FlutterLogo(size: 100),
    );
  }
}
```

### Available Simulations

| Simulation | Effect |
|------------|--------|
| `SpringSimulation` | Springy bounce |
| `GravitySimulation` | Falling with gravity |
| `FrictionSimulation` | Deceleration |
| `BouncingScrollSimulation` | Scroll bounce |
| `ClampingScrollSimulation` | Scroll with fling |

---

## 5. Hero Animations

Shared element transitions between screens.

```dart
// Screen A — origin
GestureDetector(
  onTap: () => Navigator.push(context, MaterialPageRoute(
    builder: (_) => DetailScreen(imageUrl: url),
  )),
  child: Hero(
    tag: 'hero-image-$id',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
    ),
  ),
)

// Screen B — destination
Hero(
  tag: 'hero-image-$id',
  child: Image.network(url, width: double.infinity, fit: BoxFit.cover),
)
```

### Custom Hero Flight

```dart
Hero(
  tag: 'hero-$id',
  flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
    return ScaleTransition(
      scale: animation.drive(Tween(begin: 0.5, end: 1.0)),
      child: fromContext.widget,
    );
  },
  child: widget,
)
```

---

## 6. Staggered Animations

Multiple animations playing in sequence or with overlapping intervals.

```dart
class StaggeredDemo extends StatefulWidget {
  @override
  State<StaggeredDemo> createState() => _StaggeredDemoState();
}

class _StaggeredDemoState extends State<StaggeredDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Stagger the intervals
    _opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)),
    );

    _slide = Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );

    _scale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.elasticOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: SlideTransition(
            position: _slide,
            child: Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          ),
        );
      },
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Staggered Animation', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
```

---

## 7. Page Transitions

```dart
// Custom page route with animation
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

// Slide from bottom
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        );
}
```

---

## 8. Lottie & Rive

### Lottie (After Effects animations)

```yaml
dependencies:
  lottie: ^3.1.0
```

```dart
Lottie.asset(
  'assets/animations/loading.json',
  width: 200,
  height: 200,
  fit: BoxFit.contain,
  repeat: true,
)

// With controller
class _LottieState extends State<LottieWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/success.json',
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        _controller.forward();
      },
    );
  }
}
```

### Rive (Interactive animations)

```yaml
dependencies:
  rive: ^0.13.0
```

```dart
RiveAnimation.asset(
  'assets/animations/character.riv',
  fit: BoxFit.cover,
  onInit: (artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      final trigger = controller.findInput<bool>('isHappy') as SMIBool;
      trigger.value = true;
    }
  },
)
```

---

## 9. Custom Painter With Animation

```dart
class AnimatedWavePainter extends CustomPainter {
  final double animationValue;
  AnimatedWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    for (var i = 0.0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.7 + sin((i / size.width * 2 * pi) + (animationValue * 2 * pi)) * 20,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AnimatedWavePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

// Usage
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return CustomPaint(
      painter: AnimatedWavePainter(_controller.value),
      size: const Size(double.infinity, 200),
    );
  },
)
```

---

## 10. Common Pitfalls

### ❌ Not Disposing AnimationController
```dart
@override
void dispose() {
  _controller.dispose(); // ALWAYS dispose!
  super.dispose();
}
```

### ❌ Missing `vsync` — Using Wrong Mixin
```dart
// One controller: SingleTickerProviderStateMixin
// Multiple controllers: TickerProviderStateMixin
```

### ❌ Rebuilding Entire Tree During Animation
```dart
// Bad — rebuilds child every frame
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Opacity(
      opacity: _controller.value,
      child: ExpensiveWidget(), // Rebuilt every frame!
    );
  },
)

// Good — child doesn't rebuild
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Opacity(opacity: _controller.value, child: child);
  },
  child: const ExpensiveWidget(), // Built once, reused
)
```

### ❌ Using Animated Widgets in Lists Without Keys
AnimatedSwitcher requires a new `Key` to detect the widget changed.

---

## 11. Interview Questions

### Q1: Implicit vs Explicit animations — when to use each?
**A**: Implicit → simple property changes without needing to control playback (AnimatedContainer, AnimatedOpacity). Explicit → need control over start/stop/repeat/reverse, listening to animation status, or chaining animations. Use `AnimationController` + `Tween` + `Curve`.

### Q2: What is `vsync` and why is it important?
**A**: `vsync` (vertical sync) connects the AnimationController to the screen's refresh rate via a `Ticker`. Prevents animations from consuming resources when the widget is off-screen or the app is backgrounded. `SingleTickerProviderStateMixin` provides a single ticker; `TickerProviderStateMixin` for multiple.

### Q3: How do Hero animations work?
**A**: Flutter overlays the Hero widget on top of both routes during the transition. It interpolates size and position from origin to destination using the same `tag`. The framework removes the Hero from both pages during flight and places a flight shuttle in the overlay.

### Q4: What is a staggered animation?
**A**: Multiple animations driven by a single `AnimationController` but with different `Interval` curves. Each sub-animation starts and ends at different points within the controller's 0–1 range, creating a choreographed sequence.

---

## 12. Practice Exercises

### Exercise 1: Animated Login
Create a login form where the email and password fields slide in from the left and right respectively with a staggered animation.

### Exercise 2: Loading Spinner
Build a custom loading spinner using `CustomPainter` + `AnimationController` that draws rotating arcs.

### Exercise 3: Photo Gallery
Build a photo gallery with Hero transitions — thumbnail grid opens to full-screen detail view.

---

## 13. Resources

- [Flutter Animations Guide](https://docs.flutter.dev/development/ui/animations)
- [Implicit vs Explicit](https://docs.flutter.dev/development/ui/animations/overview)
- [Lottie for Flutter](https://pub.dev/packages/lottie)
- [Rive for Flutter](https://pub.dev/packages/rive)

---

[← Previous: Local Storage](../07_local_storage/07_local_storage.md) | [Next: Platform Integration →](../09_platform_integration/09_platform_integration.md) | [Back to README](../../README.md)
