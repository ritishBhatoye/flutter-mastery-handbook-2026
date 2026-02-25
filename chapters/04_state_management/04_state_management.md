# Chapter 04 — State Management

> **Goal**: Understand and compare every major state management approach in Flutter — from `setState` to Riverpod and Bloc.

---

## Table of Contents

1. [Why State Management?](#1-why-state-management)
2. [setState](#2-setstate)
3. [InheritedWidget](#3-inheritedwidget)
4. [Provider](#4-provider)
5. [Riverpod](#5-riverpod)
6. [Bloc / Cubit](#6-bloc--cubit)
7. [GetX](#7-getx)
8. [Comparison Matrix](#8-comparison-matrix)
9. [Decision Flowchart](#9-decision-flowchart)
10. [Common Pitfalls](#10-common-pitfalls)
11. [Interview Questions](#11-interview-questions)
12. [Practice Exercises](#12-practice-exercises)
13. [Resources](#13-resources)

---

## 1. Why State Management?

**State** = any data that affects the UI at any point in time.

```
┌─────────────────────────────────────────────┐
│           Types of State                     │
├──────────────────┬──────────────────────────┤
│  Ephemeral       │  App State               │
│  (Local/UI)      │  (Shared/Global)         │
├──────────────────┼──────────────────────────┤
│  • Animation     │  • User session          │
│  • Tab index     │  • Shopping cart          │
│  • Form input    │  • Notifications         │
│  • Page scroll   │  • App preferences       │
│                  │  • API data              │
│  → setState()    │  → State management      │
│                  │    solution              │
└──────────────────┴──────────────────────────┘
```

---

## 2. setState

The simplest form — built into every `StatefulWidget`.

```dart
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$_count', style: const TextStyle(fontSize: 48))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### When to Use
- ✅ Simple, local UI state (toggle, counter, form field)
- ✅ Single-widget scope
- ❌ NOT for shared state across widgets
- ❌ NOT for complex business logic

### Problems with setState at Scale
```
Widget A (has data)
  └── Widget B
        └── Widget C
              └── Widget D (needs data)

Problem: Must pass data through B and C as constructor params
= "Prop drilling" — messy and unscalable
```

---

## 3. InheritedWidget

Flutter's built-in mechanism for passing data down the widget tree efficiently.

```dart
class AppState extends InheritedWidget {
  final int counter;
  final VoidCallback increment;

  const AppState({
    super.key,
    required this.counter,
    required this.increment,
    required super.child,
  });

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppState>()!;
  }

  @override
  bool updateShouldNotify(AppState oldWidget) {
    return counter != oldWidget.counter;
  }
}

// Usage
class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    return Text('${state.counter}');
  }
}
```

> 💡 Provider and Riverpod are built on top of InheritedWidget.

---

## 4. Provider

The recommended "simple" state management solution. Wraps InheritedWidget with a cleaner API.

### Setup
```yaml
# pubspec.yaml
dependencies:
  provider: ^6.1.0
```

### ChangeNotifier with Provider

```dart
// 1. Create a ChangeNotifier
class CounterNotifier extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    if (_count > 0) {
      _count--;
      notifyListeners();
    }
  }
}

// 2. Provide it
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CounterNotifier(),
      child: const MyApp(),
    ),
  );
}

// 3. Consume it
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rebuilds when count changes
            Consumer<CounterNotifier>(
              builder: (context, counter, child) {
                return Text('${counter.count}', style: const TextStyle(fontSize: 48));
              },
            ),
            const SizedBox(height: 16),
            // Read without rebuilding (for callbacks)
            ElevatedButton(
              onPressed: () => context.read<CounterNotifier>().increment(),
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Provider Types

| Type | Purpose |
|------|---------|
| `Provider<T>` | Provide a value (no updates) |
| `ChangeNotifierProvider<T>` | Provide a ChangeNotifier |
| `FutureProvider<T>` | Provide from a Future |
| `StreamProvider<T>` | Provide from a Stream |
| `MultiProvider` | Combine multiple providers |
| `ProxyProvider` | Provider that depends on another |

### context.watch vs context.read vs Consumer

```dart
// context.watch<T>() — Listens for changes, causes rebuild
final count = context.watch<CounterNotifier>().count; // In build()

// context.read<T>() — One-time read, NO rebuild
context.read<CounterNotifier>().increment(); // In callbacks

// Consumer<T> — Scoped rebuild (more efficient)
Consumer<CounterNotifier>(
  builder: (context, counter, child) {
    return Text('${counter.count}');
  },
  child: const ExpensiveWidget(), // Not rebuilt
);

// Selector<T, S> — Only rebuild when selected value changes
Selector<CounterNotifier, int>(
  selector: (context, counter) => counter.count,
  builder: (context, count, child) {
    return Text('$count');
  },
);
```

---

## 5. Riverpod

The evolution of Provider. Compile-safe, testable, no BuildContext dependency.

### Setup
```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.6.0

dev_dependencies:
  riverpod_generator: ^2.6.0
  build_runner: ^2.4.0
```

### Provider Types

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Simple value provider
final greetingProvider = Provider<String>((ref) {
  return 'Hello, Riverpod!';
});

// 2. StateProvider — simple mutable state
final counterProvider = StateProvider<int>((ref) => 0);

// 3. StateNotifierProvider — complex state
class TodoNotifier extends StateNotifier<List<String>> {
  TodoNotifier() : super([]);

  void add(String todo) {
    state = [...state, todo];
  }

  void remove(int index) {
    state = [...state]..removeAt(index);
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, List<String>>((ref) {
  return TodoNotifier();
});

// 4. FutureProvider — async data
final userProvider = FutureProvider<User>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUser();
});

// 5. StreamProvider — stream data
final messagesProvider = StreamProvider<List<Message>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages();
});

// 6. NotifierProvider (Riverpod 2.0+ — recommended)
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0; // Initial state

  void increment() => state++;
  void decrement() => state--;
}

final counterNotifierProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

// 7. AsyncNotifierProvider
class UserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    return ref.watch(userRepositoryProvider).getUser();
  }

  Future<void> updateName(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(userRepositoryProvider).updateName(name);
    });
  }
}

final userNotifierProvider = AsyncNotifierProvider<UserNotifier, User>(
  UserNotifier.new,
);
```

### Consuming in UI

```dart
// Wrap app with ProviderScope
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// ConsumerWidget (replaces StatelessWidget)
class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterNotifierProvider);

    return Scaffold(
      body: Center(child: Text('$count', style: const TextStyle(fontSize: 48))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterNotifierProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// AsyncValue handling
class UserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userNotifierProvider);

    return userAsync.when(
      data: (user) => Text('Hello, ${user.name}'),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### ref.watch vs ref.read vs ref.listen

```dart
// ref.watch — reactive, causes rebuild
final count = ref.watch(counterProvider); // In build()

// ref.read — one-time read, NO rebuild
ref.read(counterProvider.notifier).increment(); // In callbacks

// ref.listen — side effect on change (e.g., show snackbar)
ref.listen(counterProvider, (previous, next) {
  if (next == 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reached 10!')),
    );
  }
});
```

---

## 6. Bloc / Cubit

Business Logic Component — separates events from states using Streams.

### Setup
```yaml
dependencies:
  flutter_bloc: ^8.1.0
  bloc: ^8.1.0
  equatable: ^2.0.5
```

### Cubit (Simpler)

```dart
// Cubit — emit states directly via functions
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}

// Usage
BlocProvider(
  create: (_) => CounterCubit(),
  child: BlocBuilder<CounterCubit, int>(
    builder: (context, count) {
      return Text('$count');
    },
  ),
)

// Trigger
context.read<CounterCubit>().increment();
```

### Bloc (Full Pattern)

```dart
// Events
sealed class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email, password;
  LoginRequested(this.email, this.password);
}
class LogoutRequested extends AuthEvent {}

// States
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepo;

  AuthBloc(this._authRepo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.login(event.email, event.password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepo.logout();
    emit(AuthInitial());
  }
}

// UI
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    return switch (state) {
      AuthInitial()  => const LoginForm(),
      AuthLoading()  => const CircularProgressIndicator(),
      AuthSuccess(user: final u) => Text('Welcome ${u.name}'),
      AuthFailure()  => const LoginForm(),
    };
  },
)
```

### Bloc Widgets

| Widget | Purpose |
|--------|---------|
| `BlocProvider` | Create and provide a Bloc |
| `BlocBuilder` | Rebuild UI on state change |
| `BlocListener` | Side effects (navigation, snackbar) |
| `BlocConsumer` | Builder + Listener combined |
| `BlocSelector` | Rebuild only when selected value changes |
| `MultiBlocProvider` | Provide multiple Blocs |
| `RepositoryProvider` | Provide repository instances |

---

## 7. GetX

Lightweight, all-in-one solution (state, navigation, DI). Controversial but popular.

```dart
// Controller
class CounterController extends GetxController {
  var count = 0.obs; // Observable

  void increment() => count++;
}

// Usage
class CounterPage extends StatelessWidget {
  final controller = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => Text('${controller.count}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

> ⚠️ **Note**: GetX works but has concerns around testability, implicit magic, and divergence from Flutter patterns. Recommended for rapid prototyping, not production apps at scale.

---

## 8. Comparison Matrix

```
┌───────────────────┬──────────┬──────────┬──────────┬──────────┬──────────┐
│ Feature           │ setState │ Provider │ Riverpod │ Bloc     │ GetX     │
├───────────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Learning curve    │ ★☆☆☆☆   │ ★★☆☆☆   │ ★★★☆☆   │ ★★★★☆   │ ★★☆☆☆   │
│ Boilerplate       │ Minimal  │ Low      │ Medium   │ High     │ Low      │
│ Scalability       │ Poor     │ Good     │ Excellent│ Excellent│ Moderate │
│ Testability       │ Poor     │ Good     │ Excellent│ Excellent│ Moderate │
│ DevTools support  │ ✅       │ ✅       │ ✅       │ ✅       │ ❌       │
│ Compile safety    │ ✅       │ ❌       │ ✅       │ ✅       │ ❌       │
│ BuildContext need │ Yes      │ Yes      │ No       │ Yes      │ No       │
│ Official support  │ Built-in │ Google   │ Community│ Community│ Community│
│ Best for          │ Tiny     │ Small    │ All sizes│ Large    │ Prototype│
└───────────────────┴──────────┴──────────┴──────────┴──────────┴──────────┘
```

---

## 9. Decision Flowchart

```
Start → Is state local to one widget?
  │
  ├── YES → Use setState()
  │
  └── NO → Is the app small/medium?
        │
        ├── YES → Do you want simplicity?
        │    │
        │    ├── YES → Use Provider
        │    └── NO  → Use Riverpod
        │
        └── NO → Is the team large / enterprise?
              │
              ├── YES → Need strong event tracing?
              │    │
              │    ├── YES → Use Bloc
              │    └── NO  → Use Riverpod
              │
              └── Rapid prototype? → GetX (then migrate)
```

### 2026 Recommendation

> **Riverpod** is the recommended default for new projects. It combines the simplicity of Provider with compile-time safety, excellent testability, and no BuildContext dependency. Use **Bloc** for large enterprise teams that benefit from the explicit event → state pattern for traceability.

---

## 10. Common Pitfalls

### ❌ Calling setState After Dispose
```dart
// Check mounted before setState in async callbacks
if (mounted) setState(() { ... });
```

### ❌ Overusing Global State
```dart
// Not everything needs global state
// Keep UI state local, only share business/app state
```

### ❌ Mutating State Directly in Riverpod
```dart
// Bad — mutating the list in place
state.add(item); // Won't trigger rebuild

// Good — create a new list
state = [...state, item];
```

### ❌ Not Using Equatable in Bloc States
```dart
// Without Equatable, Bloc can't tell if states are equal
// = unnecessary rebuilds

// Good
class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}
```

---

## 11. Interview Questions

### Q1: What is the difference between ephemeral and app state?
**A**: Ephemeral (local) state is contained within a single widget — animation state, form input, tab index. Use `setState()`. App state is shared across multiple widgets/screens — user session, cart, preferences. Use a state management solution like Provider, Riverpod, or Bloc.

### Q2: How does Provider work under the hood?
**A**: Provider wraps `InheritedWidget` with a simpler API. It uses `InheritedProvider` which stores the provided object and notifies dependent widgets when `ChangeNotifier.notifyListeners()` is called. `context.watch()` calls `dependOnInheritedWidgetOfExactType()`, which registers the widget for rebuilds.

### Q3: What are the advantages of Riverpod over Provider?
**A**: (1) No BuildContext needed — providers are global objects. (2) Compile-time safety — errors caught before runtime. (3) Better testability — providers can be overridden per test. (4) Multiple providers of the same type. (5) Provider dependencies with `ref.watch()`. (6) Auto-dispose when no longer listened to.

### Q4: Explain the Bloc pattern.
**A**: Bloc separates business logic from UI using streams. Events (user actions) are dispatched to the Bloc. The Bloc processes events through `on<Event>` handlers and emits new States. UI rebuilds based on state changes. This creates a unidirectional data flow: UI → Event → Bloc → State → UI.

### Q5: When would you choose Bloc over Riverpod?
**A**: Choose Bloc when: (1) Large team needs explicit event traceability (every state change has a named event). (2) Need Bloc DevTools for debugging event/state history. (3) Complex event transformations (debounce, throttle, concurrent events). (4) Team is already trained on Bloc.

---

## 12. Practice Exercises

### Exercise 1: Todo App — 4 Ways
Build the same Todo app using: Provider, Riverpod, Bloc, and GetX. Each should support: add, remove, toggle complete, filter by completed/all.

### Exercise 2: Shopping Cart
Build a shopping cart with products list, cart, and checkout. Use Riverpod. Handle: add to cart, remove, update quantity, calculate total.

### Exercise 3: Theme Switcher
Create a light/dark theme switcher that persists the preference. Use Provider + SharedPreferences.

---

## 13. Resources

- [Flutter State Management Docs](https://docs.flutter.dev/data-and-backend/state-mgmt)
- [Provider Package](https://pub.dev/packages/provider)
- [Riverpod Documentation](https://riverpod.dev/)
- [Bloc Library](https://bloclibrary.dev/)
- [GetX Documentation](https://pub.dev/packages/get)

---

[← Previous: Flutter Basics](../03_flutter_basics/03_flutter_basics.md) | [Next: Navigation & Routing →](../05_navigation_routing/05_navigation_routing.md) | [Back to README](../../README.md)
