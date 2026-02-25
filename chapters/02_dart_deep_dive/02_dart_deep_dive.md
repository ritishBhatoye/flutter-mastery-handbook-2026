# Chapter 02 — Dart Deep Dive

> **Goal**: Master the Dart programming language — from syntax to advanced async patterns, OOP, null safety, and functional programming.

---

## Table of Contents

1. [Dart Overview](#1-dart-overview)
2. [Syntax & Type System](#2-syntax--type-system)
3. [Object-Oriented Programming](#3-object-oriented-programming)
4. [Null Safety](#4-null-safety)
5. [Collections & Generics](#5-collections--generics)
6. [Pattern Matching & Records (Dart 3+)](#6-pattern-matching--records-dart-3)
7. [Functional Programming Features](#7-functional-programming-features)
8. [Asynchronous Programming](#8-asynchronous-programming)
9. [Generators](#9-generators)
10. [Exception Handling](#10-exception-handling)
11. [Isolates & Concurrency](#11-isolates--concurrency)
12. [Tips & Tricks](#12-tips--tricks)
13. [Common Pitfalls](#13-common-pitfalls)
14. [Interview Questions](#14-interview-questions)
15. [Practice Exercises](#15-practice-exercises)
16. [Resources](#16-resources)

---

## 1. Dart Overview

Dart is a **client-optimized**, **strongly typed**, **null-safe** programming language developed by Google.

### Key Properties

| Property | Value |
|----------|-------|
| Typing | Strong, sound, with type inference |
| Null Safety | Sound (since Dart 2.12, required since Dart 3) |
| Compilation | JIT (debug) + AOT (release) |
| Concurrency | Single-threaded event loop + Isolates |
| Paradigm | Object-oriented + functional features |
| Package Manager | `pub` (pub.dev) |

### Dart Compilation Modes

```
┌───────────────────────────────────────────────────────┐
│                    Dart Compilation                    │
├───────────────────────┬───────────────────────────────┤
│     JIT (Debug)       │        AOT (Release)          │
├───────────────────────┼───────────────────────────────┤
│ • Runs in Dart VM     │ • Compiles to native ARM/x64  │
│ • Enables Hot Reload  │ • Fast startup                │
│ • Slower execution    │ • Smaller memory footprint    │
│ • Debug info included │ • No reflection               │
│ • dartdev / dart run  │ • dart compile exe            │
└───────────────────────┴───────────────────────────────┘
```

---

## 2. Syntax & Type System

### Variables & Constants

```dart
// Type inference
var name = 'Dart';              // String inferred
var count = 42;                 // int inferred
var price = 9.99;               // double inferred
var active = true;              // bool inferred

// Explicit types
String language = 'Dart';
int version = 3;
double pi = 3.14159;
bool isReady = true;

// Runtime constants (can be set once, at runtime)
final now = DateTime.now();
final String greeting = 'Hello';

// Compile-time constants (must be known at compile time)
const maxRetries = 3;
const String appName = 'MyApp';

// Late initialization
late String description;        // Must be set before access
late final cache = _loadCache(); // Lazy initialization

// Dynamic (avoid when possible)
dynamic anything = 42;
anything = 'now a string';     // No compile-time check
```

### Built-in Types

```dart
// Numbers
int age = 25;                   // 64-bit integer
double height = 5.9;            // 64-bit floating point
num value = 42;                 // int or double

// Strings
String s1 = 'single quotes';   // Preferred
String s2 = "double quotes";
String s3 = '''
  Multi-line
  string
''';
String s4 = 'Hello $name, length is ${name.length}'; // Interpolation

// Booleans
bool flag = true;

// Symbols (rarely used directly)
Symbol sym = #mySymbol;

// Runes (Unicode)
var heart = '\u2764';           // ❤
var emoji = '\u{1F600}';        // 😀
```

### Operators

```dart
// Arithmetic
5 + 3;    // 8
5 - 3;    // 2
5 * 3;    // 15
5 / 3;    // 1.6667 (double)
5 ~/ 3;   // 1 (integer division)
5 % 3;    // 2 (modulo)

// Comparison
5 == 3;   // false
5 != 3;   // true
5 > 3;    // true
5 >= 5;   // true

// Logical
true && false; // false
true || false; // true
!true;         // false

// Type test
value is String;    // true if String
value is! int;      // true if NOT int

// Cascade
final paint = Paint()
  ..color = Colors.blue
  ..strokeWidth = 2.0
  ..style = PaintingStyle.fill;

// Null-aware (see Null Safety section)
a ?? b;       // If a is null, use b
a ??= b;      // Assign b to a if a is null
a?.method();   // Call method only if a is not null
a!.method();   // Assert a is non-null

// Spread
[...list1, ...list2]
{...map1, ...map2}
```

### Functions

```dart
// Standard function
int add(int a, int b) {
  return a + b;
}

// Arrow syntax (single expression)
int multiply(int a, int b) => a * b;

// Optional positional parameters
String greet(String name, [String? title]) {
  return title != null ? '$title $name' : 'Hello $name';
}

// Named parameters
void createUser({
  required String name,
  required String email,
  int age = 0,       // Default value
  String? bio,       // Optional
}) {
  // ...
}
createUser(name: 'Alice', email: 'alice@example.com');

// First-class functions
final square = (int x) => x * x;
final result = square(5); // 25

// Function as parameter
void execute(int Function(int) fn) {
  print(fn(5));
}
execute(square); // 25

// Typedef
typedef Predicate<T> = bool Function(T);
bool isEven(int n) => n % 2 == 0;
Predicate<int> check = isEven;
```

### Control Flow

```dart
// If-else
if (score >= 90) {
  grade = 'A';
} else if (score >= 80) {
  grade = 'B';
} else {
  grade = 'C';
}

// Ternary
final status = isActive ? 'Active' : 'Inactive';

// Switch (classic)
switch (command) {
  case 'open':
    open();
    break;
  case 'close':
    close();
    break;
  default:
    print('Unknown');
}

// Switch expression (Dart 3+)
final message = switch (status) {
  Status.loading => 'Loading...',
  Status.success => 'Done!',
  Status.error   => 'Failed!',
};

// For loops
for (var i = 0; i < 10; i++) { /**/ }
for (final item in list) { /**/ }

// While
while (condition) { /**/ }
do { /**/ } while (condition);

// Collection if/for (in literals)
final items = [
  'always',
  if (showExtra) 'conditional',
  for (var i = 0; i < 3; i++) 'item_$i',
];

// Assert (debug only)
assert(price > 0, 'Price must be positive');
```

---

## 3. Object-Oriented Programming

### Classes

```dart
class Animal {
  // Instance fields
  final String name;
  int _age; // Private (library-level)

  // Constructor
  Animal(this.name, this._age);

  // Named constructor
  Animal.baby(this.name) : _age = 0;

  // Factory constructor
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(json['name'] as String, json['age'] as int);
  }

  // Getter
  int get age => _age;

  // Setter
  set age(int value) {
    if (value >= 0) _age = value;
  }

  // Method
  String speak() => '$name says hello!';

  // Operator overloading
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Animal && name == other.name && _age == other._age;

  @override
  int get hashCode => Object.hash(name, _age);

  @override
  String toString() => 'Animal($name, age: $_age)';
}
```

### Inheritance

```dart
class Dog extends Animal {
  final String breed;

  Dog(super.name, super.age, this.breed);

  @override
  String speak() => '$name barks!';

  // Additional method
  void fetch() => print('$name fetches the ball!');
}

// Usage
final dog = Dog('Buddy', 3, 'Golden Retriever');
print(dog.speak()); // Buddy barks!
dog.fetch();        // Buddy fetches the ball!
```

### Abstract Classes & Interfaces

```dart
// Abstract class — cannot be instantiated
abstract class Shape {
  double get area;
  double get perimeter;
  void describe() => print('Shape: area=$area, perimeter=$perimeter');
}

// Every class is implicitly an interface
class Circle extends Shape {
  final double radius;
  Circle(this.radius);

  @override
  double get area => 3.14159 * radius * radius;

  @override
  double get perimeter => 2 * 3.14159 * radius;
}

// Implementing an interface (must implement all members)
class MockShape implements Shape {
  @override
  double get area => 0;
  @override
  double get perimeter => 0;
  @override
  void describe() {}
}
```

### Mixins

```dart
mixin Flyable {
  void fly() => print('Flying!');
}

mixin Swimmable {
  void swim() => print('Swimming!');
}

class Duck extends Animal with Flyable, Swimmable {
  Duck(super.name, super.age);

  @override
  String speak() => '$name quacks!';
}

final duck = Duck('Donald', 2);
duck.fly();   // Flying!
duck.swim();  // Swimming!
duck.speak(); // Donald quacks!
```

### Sealed Classes (Dart 3+)

```dart
// Sealed = restricted set of subtypes (exhaustive in switch)
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}

class Loading<T> extends Result<T> {
  const Loading();
}

// Exhaustive switch — compiler warns if a case is missing
String handleResult(Result<String> result) {
  return switch (result) {
    Success(:final data)      => 'Got: $data',
    Failure(:final message)   => 'Error: $message',
    Loading()                 => 'Loading...',
  };
}
```

### Extension Methods

```dart
extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
}

// Usage
print('hello'.capitalize()); // Hello
print('a@b.com'.isEmail);    // true
```

### Extension Types (Dart 3.3+)

```dart
// Zero-cost wrapper for compile-time type safety
extension type UserId(int id) {
  // Methods on the wrapper
  bool get isValid => id > 0;
}

extension type Email(String value) {
  bool get isValid => value.contains('@');
}

// Usage — no runtime overhead
void sendEmail(Email email) {
  if (email.isValid) print('Sending to $email');
}

final id = UserId(42);
final email = Email('dart@google.com');
sendEmail(email); // ✅
// sendEmail('raw_string'); // ❌ Compile error
```

### Enums with Members

```dart
enum Priority {
  low('Low', 1),
  medium('Medium', 2),
  high('High', 3),
  critical('Critical', 4);

  final String label;
  final int value;

  const Priority(this.label, this.value);

  bool get isUrgent => value >= 3;

  @override
  String toString() => label;
}

// Usage
final p = Priority.high;
print(p.label);    // High
print(p.isUrgent); // true
```

---

## 4. Null Safety

Dart has **sound null safety** — the type system guarantees non-nullable variables never contain `null`.

### Core Concepts

```dart
// Non-nullable (default) — CANNOT be null
String name = 'Dart';
// name = null; // ❌ Compile error

// Nullable — CAN be null
String? nickname;
nickname = null; // ✅

// The null-aware operators
String? value;

// ?? — Default value if null
String result = value ?? 'default';

// ??= — Assign if null
value ??= 'assigned';

// ?. — Null-safe member access
int? length = value?.length;

// ! — Non-null assertion (throws if null!)
int forcedLength = value!.length; // RuntimeError if null

// ?.. — Null-safe cascade
value
  ?..trim()
  ..toUpperCase();
```

### Null Safety Flow Analysis

```dart
void process(String? input) {
  // Type promotion — Dart knows input is non-null after check
  if (input == null) return;

  // input is promoted to String (non-nullable) here
  print(input.length); // ✅ No ?. needed

  // Also works with is checks
  if (input is String) {
    print(input.toUpperCase());
  }
}
```

### Late Variables

```dart
class UserProfile {
  // Promise: will be initialized before first access
  late final String name;

  // Lazy initialization — computed on first access
  late final int hash = _computeExpensiveHash();

  int _computeExpensiveHash() {
    print('Computing hash...');
    return name.hashCode;
  }
}
```

### Best Practices

```
┌─────────────────────────────────────────────────┐
│           Null Safety Decision Tree              │
├─────────────────────────────────────────────────┤
│                                                  │
│  Can the value be null?                          │
│  ├── NO  → Use non-nullable type: String         │
│  └── YES → Use nullable type: String?            │
│            │                                     │
│            ├── Need a default? → Use ??           │
│            ├── Need to call methods? → Use ?.     │
│            ├── 100% sure it's not null? → Use !   │
│            │   ⚠️ DANGEROUS — avoid if possible   │
│            └── Late init? → Use late              │
│                ⚠️ Throws if accessed before init  │
│                                                  │
└─────────────────────────────────────────────────┘
```

> 🚨 **Rule**: Avoid `!` as much as possible. Prefer `?`, `??`, or flow analysis.

---

## 5. Collections & Generics

### Collections

```dart
// List (ordered, indexable)
final fruits = <String>['apple', 'banana', 'cherry'];
fruits.add('date');
fruits.removeAt(0);
final first = fruits.first;
final mapped = fruits.map((f) => f.toUpperCase()).toList();

// Set (unordered, unique)
final tags = <String>{'dart', 'flutter', 'dart'}; // {'dart', 'flutter'}
tags.add('mobile');
tags.contains('dart'); // true
final union = tags.union({'web', 'dart'});
final inter = tags.intersection({'dart', 'web'});

// Map (key-value pairs)
final scores = <String, int>{
  'Alice': 95,
  'Bob': 87,
  'Charlie': 92,
};
scores['Dave'] = 88;
scores.forEach((name, score) => print('$name: $score'));
final topScorer = scores.entries
    .reduce((a, b) => a.value > b.value ? a : b);

// Unmodifiable collections
final immutableList = List.unmodifiable([1, 2, 3]);
final immutableMap = Map.unmodifiable({'a': 1});
```

### Generics

```dart
// Generic class
class Box<T> {
  final T value;
  const Box(this.value);

  R transform<R>(R Function(T) fn) => fn(value);
}

final intBox = Box<int>(42);
final strResult = intBox.transform((v) => 'Value: $v'); // 'Value: 42'

// Generic with bounds
class NumberBox<T extends num> {
  final T value;
  NumberBox(this.value);

  bool get isPositive => value > 0;
}

// Generic typedef
typedef JsonMap = Map<String, dynamic>;
typedef FromJson<T> = T Function(JsonMap);
typedef Predicate<T> = bool Function(T);

// Generic extension
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
```

---

## 6. Pattern Matching & Records (Dart 3+)

### Records

```dart
// Record type — lightweight, immutable tuples
(int, String) getUser() => (1, 'Alice');

// Named fields in records
({int id, String name}) getUserNamed() => (id: 1, name: 'Alice');

// Destructuring
final (id, name) = getUser();
print('$id: $name'); // 1: Alice

final (:id, :name) = getUserNamed(); // Shorthand destructuring
```

### Pattern Matching

```dart
// Variable patterns
final (a, b) = (1, 2);

// List patterns
final [first, second, ...rest] = [1, 2, 3, 4, 5];
// first=1, second=2, rest=[3,4,5]

// Map patterns
final {'name': userName, 'age': userAge} = {'name': 'Bob', 'age': 30};

// Object patterns
class Point {
  final double x, y;
  Point(this.x, this.y);
}

final Point(:x, :y) = Point(3, 4);

// Switch with patterns
String describeValue(Object value) {
  return switch (value) {
    int n when n < 0   => 'Negative int: $n',
    int n              => 'Positive int: $n',
    String s when s.isEmpty => 'Empty string',
    String s           => 'String: $s',
    (int a, int b)     => 'Pair: ($a, $b)',
    [int a, ..., int z] => 'List from $a to $z',
    {'key': String v}  => 'Map with key=$v',
    _                  => 'Unknown: $value',
  };
}

// If-case
void process(Object data) {
  if (data case {'users': List<Map> users}) {
    for (final user in users) {
      print(user['name']);
    }
  }
}

// Guard clauses
final result = switch (score) {
  >= 90 => 'A',
  >= 80 => 'B',
  >= 70 => 'C',
  >= 60 => 'D',
  _     => 'F',
};
```

---

## 7. Functional Programming Features

### Higher-Order Functions

```dart
// Functions that take or return functions
List<int> filter(List<int> list, bool Function(int) predicate) {
  return [for (final item in list) if (predicate(item)) item];
}

final evens = filter([1, 2, 3, 4, 5], (n) => n.isEven); // [2, 4]

// Common collection methods (all higher-order)
final numbers = [1, 2, 3, 4, 5];

numbers.map((n) => n * 2);              // [2, 4, 6, 8, 10]
numbers.where((n) => n > 3);            // [4, 5]
numbers.reduce((a, b) => a + b);        // 15
numbers.fold<String>('', (s, n) => '$s$n'); // '12345'
numbers.every((n) => n > 0);            // true
numbers.any((n) => n > 4);              // true
numbers.expand((n) => [n, n * 10]);     // [1,10,2,20,3,30,4,40,5,50]
```

### Closures

```dart
// A closure captures variables from its enclosing scope
Function makeAdder(int addend) {
  return (int value) => value + addend; // addend is "captured"
}

final add5 = makeAdder(5);
print(add5(3));  // 8
print(add5(10)); // 15

// Practical example: event handler factory
List<VoidCallback> createHandlers(List<String> labels) {
  return labels.map((label) => () => print('Clicked: $label')).toList();
}
```

### Function Composition

```dart
// Compose functions manually
T Function(S) compose<S, T, R>(
  T Function(R) f,
  R Function(S) g,
) {
  return (S x) => f(g(x));
}

final doubleIt = (int x) => x * 2;
final addOne = (int x) => x + 1;
final doubleThenAdd = compose(addOne, doubleIt);
print(doubleThenAdd(5)); // 11 → (5*2)+1

// Pipeline with cascade
final result = [1, 2, 3, 4, 5]
    .where((n) => n.isOdd)
    .map((n) => n * n)
    .reduce((a, b) => a + b); // 1 + 9 + 25 = 35
```

---

## 8. Asynchronous Programming

### Event Loop

```
┌──────────────────────────────────────────────┐
│              Dart Event Loop                  │
│                                              │
│  ┌──────────┐    ┌──────────────────┐        │
│  │  Event    │    │  Microtask       │        │
│  │  Queue    │    │  Queue           │        │
│  │          │    │  (scheduleMicro-  │        │
│  │ • I/O    │    │   task, Future    │        │
│  │ • Timer  │    │   .then)         │        │
│  │ • User   │    │                  │        │
│  │   input  │    │  ⚡ Higher        │        │
│  │          │    │    priority      │        │
│  └──────┬───┘    └────────┬─────────┘        │
│         │                 │                  │
│         └────────┬────────┘                  │
│                  ▼                           │
│         ┌──────────────┐                     │
│         │  Event Loop  │ ← runs forever      │
│         │  1. Drain    │                     │
│         │   microtasks │                     │
│         │  2. Process  │                     │
│         │   next event │                     │
│         └──────────────┘                     │
│                                              │
└──────────────────────────────────────────────┘
```

### Futures

```dart
// A Future represents a value that will be available later
Future<String> fetchUserName() async {
  // Simulate network call
  await Future.delayed(const Duration(seconds: 2));
  return 'Alice';
}

// Using async/await
Future<void> main() async {
  print('Fetching...');
  final name = await fetchUserName();
  print('Hello, $name!');
}

// Using .then()
fetchUserName()
    .then((name) => print('Hello, $name!'))
    .catchError((e) => print('Error: $e'))
    .whenComplete(() => print('Done'));

// Future.wait — parallel execution
Future<void> loadAll() async {
  final results = await Future.wait([
    fetchUsers(),
    fetchProducts(),
    fetchSettings(),
  ]);
  // All three complete before this line
}

// Future.any — first to complete wins
final fastest = await Future.any([
  fetchFromServer1(),
  fetchFromServer2(),
]);
```

### Streams

```dart
// A Stream is a sequence of async events
Stream<int> countStream(int max) async* {
  for (var i = 1; i <= max; i++) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
  }
}

// Listening to a stream
final subscription = countStream(5).listen(
  (value) => print('Got: $value'),
  onError: (error) => print('Error: $error'),
  onDone: () => print('Stream completed'),
  cancelOnError: false,
);

// Later: cancel the subscription
await subscription.cancel();

// Stream transformations
countStream(10)
    .where((n) => n.isEven)
    .map((n) => 'Even: $n')
    .take(3)
    .listen(print);
// Output: Even: 2, Even: 4, Even: 6

// StreamController — creating streams manually
final controller = StreamController<String>();

controller.stream.listen((data) => print(data));

controller.add('Hello');
controller.add('World');
await controller.close();

// Broadcast stream (multiple listeners)
final broadcastController = StreamController<int>.broadcast();
broadcastController.stream.listen((v) => print('Listener 1: $v'));
broadcastController.stream.listen((v) => print('Listener 2: $v'));
broadcastController.add(42); // Both listeners receive 42
```

### Stream Types Comparison

```
┌─────────────────────┬──────────────────────────────────┐
│ Single-subscription │ Broadcast                        │
├─────────────────────┼──────────────────────────────────┤
│ Only ONE listener   │ Multiple listeners               │
│ Begins on listen    │ Events fire regardless           │
│ Pauses when no one  │ Late listeners miss past events  │
│   listens           │                                  │
│ File reads, HTTP    │ UI events, sensor data           │
└─────────────────────┴──────────────────────────────────┘
```

### Completer

```dart
// When you need to create a Future that you complete manually
Future<String> askUser() {
  final completer = Completer<String>();

  // Simulate async callback-based API
  Timer(const Duration(seconds: 1), () {
    completer.complete('User response');
    // or: completer.completeError('Something went wrong');
  });

  return completer.future;
}
```

---

## 9. Generators

### Synchronous Generator (Iterable)

```dart
// sync* yields items lazily
Iterable<int> naturals(int max) sync* {
  for (var i = 1; i <= max; i++) {
    yield i;
  }
}

// yield* delegates to another iterable
Iterable<int> range(int start, int end) sync* {
  yield* Iterable.generate(end - start, (i) => start + i);
}

// Usage — lazy evaluation
for (final n in naturals(1000000)) {
  if (n > 5) break; // Only generates 6 values!
  print(n);
}
```

### Asynchronous Generator (Stream)

```dart
// async* yields items asynchronously
Stream<String> fetchItems() async* {
  final urls = ['url1', 'url2', 'url3'];
  for (final url in urls) {
    final data = await http.get(Uri.parse(url));
    yield data.body;
  }
}

// yield* delegates to another stream
Stream<int> mergedStreams() async* {
  yield* countStream(3);
  yield* countStream(3); // Continues after first completes
}
```

---

## 10. Exception Handling

### Try-Catch-Finally

```dart
try {
  final result = riskyOperation();
  print(result);
} on FormatException catch (e, stackTrace) {
  // Catch specific exception type
  print('Format error: $e');
  print('Stack trace: $stackTrace');
} on HttpException {
  // Catch without binding
  print('Network error');
} catch (e, s) {
  // Catch everything else
  print('Unknown error: $e');
  print('Stack: $s');
  rethrow; // Re-throw to propagate
} finally {
  // Always runs
  cleanup();
}
```

### Custom Exceptions

```dart
// Custom exception
class AppException implements Exception {
  final String message;
  final int? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  final int statusCode;

  const NetworkException(super.message, {required this.statusCode})
      : super(code: statusCode);
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException(super.message, {required this.fieldErrors});
}

// Usage
Future<User> fetchUser(int id) async {
  try {
    final response = await dio.get('/users/$id');
    if (response.statusCode != 200) {
      throw NetworkException(
        'Failed to fetch user',
        statusCode: response.statusCode!,
      );
    }
    return User.fromJson(response.data);
  } on DioException catch (e) {
    throw NetworkException(
      e.message ?? 'Unknown network error',
      statusCode: e.response?.statusCode ?? 0,
    );
  }
}
```

### Result Pattern (No Exceptions)

```dart
// Using sealed classes for error handling without exceptions
sealed class Result<T> {
  const Result();
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final String error;
  const Err(this.error);
}

// Usage
Result<User> fetchUser(int id) {
  try {
    final user = api.getUser(id);
    return Ok(user);
  } catch (e) {
    return Err(e.toString());
  }
}

// Consuming
final result = fetchUser(1);
switch (result) {
  case Ok(:final value): print('User: ${value.name}');
  case Err(:final error): print('Error: $error');
}
```

---

## 11. Isolates & Concurrency

### Understanding Isolates

```
┌─────────────────────────────────────────────┐
│  Main Isolate          Worker Isolate       │
│  ┌──────────┐          ┌──────────┐         │
│  │ Dart VM  │ ──msg──▶ │ Dart VM  │         │
│  │          │ ◀──msg── │          │         │
│  │ • UI     │          │ • Heavy  │         │
│  │ • Events │          │   compute│         │
│  │ • State  │          │ • No UI  │         │
│  └──────────┘          └──────────┘         │
│                                             │
│  Each isolate has its own:                  │
│  • Memory heap                              │
│  • Event loop                               │
│  • No shared state (message passing only)   │
└─────────────────────────────────────────────┘
```

### compute() — Simple Isolate

```dart
// Flutter's convenience function for one-shot isolate work
import 'package:flutter/foundation.dart';

Future<List<User>> parseUsers(String jsonString) async {
  return await compute(_parseUsersInBackground, jsonString);
}

// Must be a top-level or static function
List<User> _parseUsersInBackground(String jsonString) {
  final List<dynamic> data = jsonDecode(jsonString);
  return data.map((json) => User.fromJson(json)).toList();
}
```

### Isolate.run() — Dart 2.19+

```dart
// Simpler API for one-shot computation
final result = await Isolate.run(() {
  // Heavy computation here
  return expensiveCalculation();
});
```

### Full Isolate Communication

```dart
// Bi-directional communication with ReceivePort/SendPort
Future<void> startWorker() async {
  final receivePort = ReceivePort();

  await Isolate.spawn(_workerEntryPoint, receivePort.sendPort);

  final sendPort = await receivePort.first as SendPort;

  final responsePort = ReceivePort();
  sendPort.send(['process', 'data', responsePort.sendPort]);

  final result = await responsePort.first;
  print('Result: $result');
}

void _workerEntryPoint(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    final List msg = message;
    final command = msg[0] as String;
    final data = msg[1] as String;
    final replyPort = msg[2] as SendPort;

    // Process and reply
    final result = '$command completed for $data';
    replyPort.send(result);
  });
}
```

---

## 12. Tips & Tricks

### 1. Cascade Notation for Fluent APIs
```dart
final list = <int>[]
  ..add(1)
  ..add(2)
  ..add(3)
  ..sort()
  ..reversed;
```

### 2. Collection `if` and `for`
```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      const Header(),
      if (showBanner) const Banner(),
      for (final item in items) ItemCard(item: item),
      if (isAdmin) const AdminPanel(),
    ],
  );
}
```

### 3. Extension Methods for Cleaner Code
```dart
extension DateTimeExt on DateTime {
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

print(DateTime.now().subtract(Duration(hours: 3)).timeAgo); // 3h ago
```

### 4. Tear-offs (Method References)
```dart
// Instead of: items.map((item) => item.toString())
items.map(item.toString); // ❌ Wrong — this is a getter

// Tear-off works with top-level and static functions
final numbers = ['1', '2', '3'];
numbers.map(int.parse); // ✅ [1, 2, 3]

// Constructor tear-off
final widgets = names.map(Text.new).toList();
```

### 5. Named Constructor `.fromJson` with Factory
```dart
class Config {
  final String apiUrl;
  final int timeout;

  const Config({required this.apiUrl, this.timeout = 30});

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        apiUrl: json['api_url'] as String,
        timeout: json['timeout'] as int? ?? 30,
      );

  factory Config.development() => const Config(
        apiUrl: 'http://localhost:8080',
        timeout: 60,
      );

  factory Config.production() => const Config(
        apiUrl: 'https://api.myapp.com',
        timeout: 15,
      );
}
```

---

## 13. Common Pitfalls

### ❌ Using `dynamic` Instead of Proper Types
```dart
// Bad
dynamic fetchData() { ... }

// Good
Future<Map<String, dynamic>> fetchData() { ... }
```

### ❌ Forgetting to `await` Futures
```dart
// Bad — fire and forget (silently drops errors)
saveData();

// Good
await saveData();

// Also good — explicitly handle later
final future = saveData();
// ... do other work ...
await future;
```

### ❌ Misusing `late` Variables
```dart
// Dangerous — throws LateInitializationError at runtime
late String name;
print(name); // 💥 

// Safe — always initialize before access
late String name;
name = 'Alice'; // ← Must happen before any read
print(name);    // ✅
```

### ❌ Stream Subscription Leaks
```dart
// Bad — no way to cancel
myStream.listen((data) => print(data));

// Good — store and cancel in dispose()
late StreamSubscription<String> _subscription;

void init() {
  _subscription = myStream.listen((data) => print(data));
}

void dispose() {
  _subscription.cancel();
}
```

### ❌ Using `!` Everywhere
```dart
// Bad — defeats the purpose of null safety
print(user!.name!.first!.toUpperCase());

// Good — use null-aware operators or pattern matching
print(user?.name?.first?.toUpperCase() ?? 'Unknown');
```

---

## 14. Interview Questions

### Q1: What is sound null safety in Dart?
**A**: Sound null safety means the type system guarantees that a non-nullable variable can never be `null` at runtime. The compiler statically verifies all paths. This eliminates an entire class of null reference errors. `String` can never be null; `String?` can be null. The "sound" part means there are no loopholes — it's enforced by the compiler and runtime.

### Q2: Explain `final` vs `const`.
**A**: `final` — set once at runtime; `const` — set at compile time. `final DateTime.now()` works but `const DateTime.now()` doesn't (not computable at compile time). `const` objects are canonicalized (same values = same instance in memory). In Flutter, `const` widgets are not rebuilt.

### Q3: What are Isolates?
**A**: Isolates are Dart's concurrency model. Each isolate has its own memory heap and event loop. They don't share memory — they communicate via message passing (`SendPort`/`ReceivePort`). This avoids race conditions and locks. Use for CPU-heavy work (JSON parsing, image processing) to keep the UI responsive.

### Q4: What is the difference between `async*` and `async`?
**A**: `async` returns a `Future<T>` — a single value computed asynchronously. `async*` returns a `Stream<T>` — a sequence of values emitted asynchronously using `yield`. Use `async*` for continuous data (sensor readings, paginated API calls).

### Q5: Explain sealed classes and when to use them.
**A**: Sealed classes (Dart 3) restrict which classes can extend them to the same library file. This enables exhaustive switch — the compiler knows all possible subtypes and warns if you miss one. Ideal for state modeling (Loading/Success/Error), algebraic data types, and the Result pattern.

### Q6: What are Records and Patterns in Dart 3?
**A**: Records are anonymous, immutable tuple-like types: `(int, String)` or `({int id, String name})`. Patterns enable destructuring and matching: `final (a, b) = record;`. Together they enable powerful, concise code especially in switch expressions, if-case statements, and function return types.

### Q7: What is extension type?
**A**: Extension types (Dart 3.3) provide compile-time wrapper types with zero runtime overhead. Unlike extension methods, they create a new type: `extension type UserId(int id) {}`. Useful for "newtype" pattern — preventing accidental misuse of raw types.

### Q8: How does Dart's event loop work?
**A**: Single-threaded. Two queues: microtask queue (higher priority, runs between events) and event queue (I/O, timers, UI events). Loop: drain all microtasks → process one event → repeat. `Future.then` schedules microtasks; `Timer`, I/O callbacks go to event queue.

### Q9: What are Generators in Dart?
**A**: Generators produce sequences lazily. `sync*` returns `Iterable<T>`, uses `yield` to emit values pulled by consumers. `async*` returns `Stream<T>`, uses `yield` to push values to listeners. Both support `yield*` to delegate to sub-generators.

### Q10: Explain the Result pattern.
**A**: Instead of using try-catch, return a sealed type `Result<T>` that is either `Ok<T>` with data or `Err<T>` with error info. Forces callers to handle both cases. Makes error handling explicit and composable. Ideal in domain/use-case layers of Clean Architecture.

---

## 15. Practice Exercises

### Exercise 1: Null Safety Practice
Write a function `safeDivide(int? a, int? b)` that:
- Returns `null` if either parameter is null
- Returns `null` if b is 0
- Returns the division result otherwise

<details>
<summary>Solution</summary>

```dart
double? safeDivide(int? a, int? b) {
  if (a == null || b == null || b == 0) return null;
  return a / b;
}
```
</details>

### Exercise 2: Stream Processing
Create a stream that emits Fibonacci numbers and take the first 10.

<details>
<summary>Solution</summary>

```dart
Stream<int> fibonacci() async* {
  int a = 0, b = 1;
  while (true) {
    yield a;
    final next = a + b;
    a = b;
    b = next;
  }
}

void main() async {
  await for (final n in fibonacci().take(10)) {
    print(n); // 0, 1, 1, 2, 3, 5, 8, 13, 21, 34
  }
}
```
</details>

### Exercise 3: Sealed Class State
Create a sealed `AuthState` with `Unauthenticated`, `Authenticating`, and `Authenticated(User)` variants. Write a function that returns a UI string for each state.

<details>
<summary>Solution</summary>

```dart
class User {
  final String name;
  User(this.name);
}

sealed class AuthState {}
class Unauthenticated extends AuthState {}
class Authenticating extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}

String describeAuth(AuthState state) {
  return switch (state) {
    Unauthenticated()      => 'Please sign in',
    Authenticating()       => 'Signing in...',
    Authenticated(:final user) => 'Welcome, ${user.name}!',
  };
}
```
</details>

### Exercise 4: Extension Methods
Write an extension on `List<int>` that adds `median`, `mode`, and `standardDeviation` getters.

<details>
<summary>Solution</summary>

```dart
import 'dart:math';

extension StatisticsExtension on List<int> {
  double get median {
    final sorted = [...this]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid].toDouble();
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }

  int get mode {
    final freq = <int, int>{};
    for (final n in this) {
      freq[n] = (freq[n] ?? 0) + 1;
    }
    return freq.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double get standardDeviation {
    final mean = reduce((a, b) => a + b) / length;
    final variance = map((n) => pow(n - mean, 2)).reduce((a, b) => a + b) / length;
    return sqrt(variance);
  }
}
```
</details>

---

## 16. Resources

### Official
- [Dart Language Tour](https://dart.dev/language)
- [Effective Dart](https://dart.dev/effective-dart)
- [Dart API Reference](https://api.dart.dev/)
- [DartPad](https://dartpad.dev/)

### Deep Dives
- [Dart Null Safety — Understanding](https://dart.dev/null-safety/understanding-null-safety)
- [Dart Patterns — Full Spec](https://dart.dev/language/patterns)
- [Dart Concurrency](https://dart.dev/language/concurrency)
- [Dart Isolates](https://dart.dev/language/isolates)

### Books
- *Dart Apprentice* — Kodeco
- *Dart in Action* — Manning

---

[← Previous: Introduction](../01_introduction/01_introduction.md) | [Next: Flutter Basics →](../03_flutter_basics/03_flutter_basics.md) | [Back to README](../../README.md)
