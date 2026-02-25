# Chapter 11 — Testing

> **Goal**: Master Flutter's testing pyramid — unit, widget, integration, golden tests, and mocking.

---

## Table of Contents

1. [Testing Pyramid](#1-testing-pyramid)
2. [Unit Testing](#2-unit-testing)
3. [Widget Testing](#3-widget-testing)
4. [Integration Testing](#4-integration-testing)
5. [Mocking with Mockito](#5-mocking-with-mockito)
6. [Golden Tests](#6-golden-tests)
7. [BLoC Testing](#7-bloc-testing)
8. [Riverpod Testing](#8-riverpod-testing)
9. [Test Coverage](#9-test-coverage)
10. [CI/CD Testing](#10-cicd-testing)
11. [Common Pitfalls](#11-common-pitfalls)
12. [Interview Questions](#12-interview-questions)
13. [Practice Exercises](#13-practice-exercises)
14. [Resources](#14-resources)

---

## 1. Testing Pyramid

```
        ╱╲
       ╱  ╲         Integration Tests
      ╱ E2E╲        • Slow, expensive
     ╱──────╲       • Test full flows
    ╱        ╲      • Real device/emulator
   ╱  Widget  ╲     Widget Tests
  ╱   Tests    ╲    • Medium speed
 ╱──────────────╲   • Test UI components
╱                ╲  • Mock dependencies
╱   Unit Tests    ╲ Unit Tests
╱──────────────────╲ • Fast, cheap
                     • Test logic in isolation
                     • Pure Dart

Ratio: ~70% Unit / ~20% Widget / ~10% Integration
```

---

## 2. Unit Testing

Test pure Dart logic — models, services, utilities, business rules.

```yaml
dev_dependencies:
  test: ^1.25.0
```

```dart
// lib/models/cart.dart
class Cart {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  void add(CartItem item) {
    final existing = _items.indexWhere((i) => i.productId == item.productId);
    if (existing != -1) {
      _items[existing] = _items[existing].copyWith(
        quantity: _items[existing].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
  }

  void remove(String productId) {
    _items.removeWhere((i) => i.productId == productId);
  }

  double get total => _items.fold(0, (sum, i) => sum + i.price * i.quantity);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => _items.isEmpty;
}

// test/models/cart_test.dart
import 'package:test/test.dart';
import 'package:my_app/models/cart.dart';

void main() {
  late Cart cart;

  setUp(() {
    cart = Cart();
  });

  group('Cart', () {
    test('starts empty', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.total, equals(0.0));
      expect(cart.itemCount, equals(0));
    });

    test('adds item correctly', () {
      cart.add(CartItem(productId: '1', name: 'Widget', price: 9.99, quantity: 1));
      expect(cart.itemCount, equals(1));
      expect(cart.items.first.name, equals('Widget'));
    });

    test('merges duplicate items', () {
      cart.add(CartItem(productId: '1', name: 'Widget', price: 9.99, quantity: 1));
      cart.add(CartItem(productId: '1', name: 'Widget', price: 9.99, quantity: 2));
      expect(cart.itemCount, equals(3));
      expect(cart.items.length, equals(1));
    });

    test('calculates total correctly', () {
      cart.add(CartItem(productId: '1', name: 'A', price: 10.0, quantity: 2));
      cart.add(CartItem(productId: '2', name: 'B', price: 5.0, quantity: 3));
      expect(cart.total, equals(35.0));
    });

    test('removes item by product ID', () {
      cart.add(CartItem(productId: '1', name: 'A', price: 10.0, quantity: 1));
      cart.add(CartItem(productId: '2', name: 'B', price: 5.0, quantity: 1));
      cart.remove('1');
      expect(cart.items.length, equals(1));
      expect(cart.items.first.productId, equals('2'));
    });
  });

  group('edge cases', () {
    test('total is 0 for empty cart', () {
      expect(cart.total, equals(0.0));
    });

    test('removing non-existent item does not throw', () {
      expect(() => cart.remove('nonexistent'), returnsNormally);
    });
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific file
flutter test test/models/cart_test.dart

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 3. Widget Testing

Test Flutter widgets in isolation — render, interact, verify.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/widgets/counter_widget.dart';

void main() {
  group('CounterWidget', () {
    testWidgets('displays initial count of 0', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CounterWidget(),
      ));

      expect(find.text('0'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('increments count on button tap', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CounterWidget()));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(); // Rebuild after setState

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('decrements count but not below 0', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CounterWidget()));

      // Count is 0, decrement should not go below
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('shows snackbar at 10', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CounterWidget()),
      ));

      // Tap 10 times
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
      }

      await tester.pumpAndSettle(); // Wait for snackbar animation

      expect(find.text('You reached 10!'), findsOneWidget);
    });
  });
}
```

### Key Finders

```dart
find.text('Hello')                    // By text content
find.byType(ElevatedButton)           // By widget type
find.byIcon(Icons.add)                // By icon
find.byKey(const Key('submit_btn'))   // By key
find.widgetWithText(ElevatedButton, 'Submit') // Widget containing text
find.descendant(of: find.byType(Card), matching: find.text('title'))
find.byTooltip('Add item')           // By tooltip
```

### Key Matchers

```dart
findsOneWidget        // Exactly one
findsNothing          // None
findsNWidgets(3)      // Exactly 3
findsAtLeastNWidgets(1) // One or more
```

### Key Actions

```dart
await tester.tap(finder);              // Tap
await tester.longPress(finder);        // Long press
await tester.drag(finder, Offset(0, -300)); // Scroll/drag
await tester.enterText(finder, 'text'); // Type text
await tester.pump();                    // Single frame rebuild
await tester.pumpAndSettle();          // Wait for all animations
await tester.pumpWidget(widget);       // Render widget
```

---

## 4. Integration Testing

End-to-end tests running on a real device or emulator.

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('complete login flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      expect(find.text('Login'), findsOneWidget);

      // Enter credentials
      await tester.enterText(find.byKey(const Key('email_field')), 'test@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify navigation to home
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
```

```bash
# Run on connected device
flutter test integration_test/app_test.dart
```

---

## 5. Mocking with Mockito

```yaml
dev_dependencies:
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

@GenerateMocks([UserRepository, AuthService])
import 'login_test.mocks.dart';

void main() {
  late MockUserRepository mockRepo;
  late MockAuthService mockAuth;

  setUp(() {
    mockRepo = MockUserRepository();
    mockAuth = MockAuthService();
  });

  test('returns user on successful login', () async {
    // Arrange
    when(mockAuth.login('test@test.com', 'pass'))
        .thenAnswer((_) async => User(id: '1', name: 'Test'));

    // Act
    final user = await mockAuth.login('test@test.com', 'pass');

    // Assert
    expect(user.name, equals('Test'));
    verify(mockAuth.login('test@test.com', 'pass')).called(1);
  });

  test('throws on invalid credentials', () async {
    when(mockAuth.login(any, any))
        .thenThrow(AuthException('Invalid credentials'));

    expect(
      () => mockAuth.login('bad@email.com', 'wrong'),
      throwsA(isA<AuthException>()),
    );
  });
}
```

### Generate Mocks

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 6. Golden Tests

Pixel-perfect visual regression tests — compares widget rendering against a saved golden image.

```dart
testWidgets('profile card golden test', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ProfileCard(
        name: 'John Doe',
        email: 'john@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
      ),
    ),
  ));

  await expectLater(
    find.byType(ProfileCard),
    matchesGoldenFile('goldens/profile_card.png'),
  );
});
```

```bash
# Generate golden files (first time)
flutter test --update-goldens

# Run golden tests (compare against saved)
flutter test
```

---

## 7. BLoC Testing

```yaml
dev_dependencies:
  bloc_test: ^9.1.0
```

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterCubit', () {
    blocTest<CounterCubit, int>(
      'emits [1] when increment is called',
      build: () => CounterCubit(),
      act: (cubit) => cubit.increment(),
      expect: () => [1],
    );

    blocTest<CounterCubit, int>(
      'emits [1, 2, 3] when increment is called 3 times',
      build: () => CounterCubit(),
      act: (cubit) {
        cubit.increment();
        cubit.increment();
        cubit.increment();
      },
      expect: () => [1, 2, 3],
    );

    blocTest<CounterCubit, int>(
      'emits [-1] when decrement is called',
      build: () => CounterCubit(),
      act: (cubit) => cubit.decrement(),
      expect: () => [-1],
    );
  });

  group('AuthBloc', () {
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful login',
      build: () {
        when(mockRepo.login(any, any))
            .thenAnswer((_) async => User(id: '1', name: 'Test'));
        return AuthBloc(mockRepo);
      },
      act: (bloc) => bloc.add(LoginRequested('test@test.com', 'pass')),
      expect: () => [AuthLoading(), isA<AuthSuccess>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on failed login',
      build: () {
        when(mockRepo.login(any, any)).thenThrow(Exception('Bad credentials'));
        return AuthBloc(mockRepo);
      },
      act: (bloc) => bloc.add(LoginRequested('bad', 'creds')),
      expect: () => [AuthLoading(), isA<AuthFailure>()],
    );
  });
}
```

---

## 8. Riverpod Testing

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('counterProvider starts at 0', () {
    final container = ProviderContainer();
    expect(container.read(counterProvider), equals(0));
    container.dispose();
  });

  test('counterProvider increments', () {
    final container = ProviderContainer();
    container.read(counterProvider.notifier).increment();
    expect(container.read(counterProvider), equals(1));
    container.dispose();
  });

  // Override providers for testing
  testWidgets('widget with overridden provider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(MockUserRepository()),
        ],
        child: const MaterialApp(home: UserPage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Mock User'), findsOneWidget);
  });
}
```

---

## 9. Test Coverage

```bash
# Generate coverage report
flutter test --coverage

# HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Coverage targets
# ✅ Good: > 80%
# 🟡 Acceptable: 60-80%
# ❌ Low: < 60%
```

---

## 10. CI/CD Testing

```yaml
# .github/workflows/test.yml
name: Flutter Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info
```

---

## 11. Common Pitfalls

### ❌ Not Using pump/pumpAndSettle
```dart
// tap() doesn't auto-rebuild
await tester.tap(finder);
await tester.pump();        // REQUIRED to rebuild
// or
await tester.pumpAndSettle(); // Wait for all animations
```

### ❌ Testing Implementation Instead of Behavior
```dart
// Bad — tests internal state
expect(widget._count, equals(1));

// Good — tests what user sees
expect(find.text('1'), findsOneWidget);
```

### ❌ Not Disposing Test Resources
```dart
final container = ProviderContainer();
addTearDown(container.dispose); // Always clean up
```

---

## 12. Interview Questions

### Q1: Unit vs Widget vs Integration test — difference?
**A**: Unit tests: pure Dart logic in isolation (models, services). Fast, no Flutter. Widget tests: render widgets, tap buttons, verify UI. Medium speed, mocked deps. Integration tests: full app on real device, test user flows end-to-end. Slow but thorough. Ratio: 70/20/10.

### Q2: What are golden tests?
**A**: Visual regression tests that compare rendered widget pixels against a saved reference image (golden file). If pixels differ, the test fails. Great for catching unintended visual changes. Run `--update-goldens` to save new references.

### Q3: How do you test async code in Flutter?
**A**: Use `async` test functions. Use `await tester.pumpAndSettle()` to wait for futures and animations. For streams, use `expectLater` with `emitsInOrder`. For BLoC, use `blocTest` which handles async internally. Mock async dependencies with `thenAnswer((_) async => value)`.

---

## 13. Practice Exercises

### Exercise 1: Model Tests
Write unit tests for a `Wallet` model: add funds, withdraw, transfer, check balance, handle overdraft.

### Exercise 2: Widget Tests
Write widget tests for a login form: validates email format, shows error on empty password, navigates on success.

### Exercise 3: BLoC Tests
Test a `TodoBloc` with events: AddTodo, ToggleTodo, DeleteTodo, FilterTodos. Verify all state transitions.

---

## 14. Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mockito](https://pub.dev/packages/mockito)
- [bloc_test](https://pub.dev/packages/bloc_test)
- [Golden Toolkit](https://pub.dev/packages/golden_toolkit)

---

[← Previous: Performance](../10_performance_optimization/10_performance_optimization.md) | [Next: Architecture →](../12_architecture_patterns/12_architecture_patterns.md) | [Back to README](../../README.md)
