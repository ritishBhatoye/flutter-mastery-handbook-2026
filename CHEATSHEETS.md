# 📋 Flutter Mastery Handbook — Cheat Sheets

> Quick-reference cards for the most common Flutter & Dart patterns.

---

## 🎯 Dart Syntax Quick Reference

```dart
// Variables
var name = 'Flutter';           // Type inferred
String lang = 'Dart';           // Explicit type
final pi = 3.14;                // Runtime constant
const gravity = 9.8;            // Compile-time constant
int? nullable;                  // Nullable type

// String interpolation
print('Hello $name, version ${lang.length}');

// Null-aware operators
String? s;
print(s ?? 'fallback');         // If null, use fallback
s ??= 'assigned';              // Assign if null
print(s?.length);              // Null-safe access
print(s!.length);              // Assert non-null (careful!)

// Collections
var list   = [1, 2, 3];
var set    = {1, 2, 3};
var map    = {'a': 1, 'b': 2};
var spread = [...list, 4, 5];  // Spread operator

// Control flow in collections
var items = [
  'always',
  if (true) 'conditional',
  for (var i in [1,2]) 'item_$i',
];

// Pattern matching (Dart 3+)
switch (shape) {
  case Circle(radius: var r) when r > 0:
    print('Circle with radius $r');
  case Square(side: var s):
    print('Square with side $s');
}

// Records
(int, String) record = (42, 'hello');
var (num, text) = record; // Destructuring
```

---

## 🧱 Widget Cheat Sheet

```
StatelessWidget              StatefulWidget
┌─────────────────┐         ┌─────────────────┐
│  build(context)  │         │  createState()   │
│    ↓             │         │    ↓             │
│  returns Widget  │         │  State<T>        │
└─────────────────┘         │  ├─ initState()  │
                            │  ├─ build()      │
                            │  ├─ setState()   │
                            │  ├─ didUpdate()  │
                            │  └─ dispose()    │
                            └─────────────────┘
```

### Common Layout Widgets

| Widget | Purpose | Key Properties |
|--------|---------|----------------|
| `Container` | Box model wrapper | padding, margin, decoration, constraints |
| `Row` | Horizontal layout | mainAxisAlignment, crossAxisAlignment, children |
| `Column` | Vertical layout | mainAxisAlignment, crossAxisAlignment, children |
| `Stack` | Overlay widgets | alignment, fit, children |
| `Expanded` | Fill remaining space | flex, child |
| `Flexible` | Flexible sizing | flex, fit, child |
| `SizedBox` | Fixed size / spacer | width, height |
| `Padding` | Add padding | padding, child |
| `ListView` | Scrollable list | builder, separated, children |
| `GridView` | Scrollable grid | count, extent, builder |
| `Wrap` | Flow layout | spacing, runSpacing, direction |
| `ConstrainedBox` | Apply constraints | constraints |

---

## 📦 State Management Decision Matrix

```
┌───────────────────┬──────────┬──────────┬──────────┬──────────┬──────────┐
│ Criteria          │ setState │ Provider │ Riverpod │ Bloc     │ GetX     │
├───────────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Learning curve    │ ★☆☆☆☆   │ ★★☆☆☆   │ ★★★☆☆   │ ★★★★☆   │ ★★☆☆☆   │
│ Scalability       │ ★☆☆☆☆   │ ★★★☆☆   │ ★★★★★   │ ★★★★★   │ ★★★☆☆   │
│ Testability       │ ★☆☆☆☆   │ ★★★☆☆   │ ★★★★★   │ ★★★★★   │ ★★☆☆☆   │
│ Boilerplate       │ ★★★★★   │ ★★★★☆   │ ★★★☆☆   │ ★★☆☆☆   │ ★★★★☆   │
│ Community support │ ★★★★★   │ ★★★★★   │ ★★★★☆   │ ★★★★★   │ ★★★☆☆   │
│ Best for          │ Tiny     │ Small-   │ Med-     │ Large    │ Rapid    │
│                   │ apps     │ Medium   │ Large    │ teams    │ proto    │
└───────────────────┴──────────┴──────────┴──────────┴──────────┴──────────┘
```

---

## 🌐 Networking Quick Reference

```dart
// HTTP GET
final response = await http.get(Uri.parse('https://api.example.com/data'));

// Dio with interceptors
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 5),
));
dio.interceptors.add(LogInterceptor());
final response = await dio.get('/users');

// JSON decode
final data = jsonDecode(response.body) as Map<String, dynamic>;

// Model from JSON (with json_serializable)
@JsonSerializable()
class User {
  final String name;
  final int age;
  User({required this.name, required this.age});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

---

## 🎨 Animation Quick Reference

```dart
// Implicit (simple)
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: _expanded ? 200 : 100,
  color: _active ? Colors.blue : Colors.grey,
);

// Explicit (full control)
class _MyState extends State<MyWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _anim, child: Icon(Icons.star));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
```

---

## 🧪 Testing Quick Reference

```dart
// Unit test
test('adds two numbers', () {
  expect(add(2, 3), equals(5));
});

// Widget test
testWidgets('shows title', (tester) async {
  await tester.pumpWidget(MaterialApp(home: MyScreen()));
  expect(find.text('Hello'), findsOneWidget);
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  expect(find.text('1'), findsOneWidget);
});

// Mock with Mocktail
class MockRepo extends Mock implements UserRepository {}

test('fetches user', () async {
  final mock = MockRepo();
  when(() => mock.getUser(1)).thenAnswer((_) async => User('Alice'));
  final user = await mock.getUser(1);
  expect(user.name, 'Alice');
});
```

---

## 📁 Project Structure (Feature-First)

```
lib/
├── app/
│   ├── app.dart                   // MaterialApp, theme, router
│   └── di.dart                    // Dependency injection setup
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── home/
│   │   └── ...
│   └── settings/
│       └── ...
└── main.dart
```

---

## ⌨️ Flutter CLI Commands

```bash
# Create project
flutter create my_app
flutter create --template=package my_package
flutter create --platforms=web,macos my_app

# Run
flutter run                      # Debug on connected device
flutter run -d chrome            # Run on Chrome
flutter run --release            # Release mode
flutter run --profile            # Profile mode

# Build
flutter build apk --release
flutter build ios --release
flutter build web
flutter build macos

# Testing
flutter test                     # All unit + widget tests
flutter test --coverage          # With coverage report
flutter test integration_test/   # Integration tests

# Packages
flutter pub get
flutter pub upgrade
flutter pub outdated
flutter pub add provider
flutter pub remove provider

# Code generation
dart run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze
dart fix --apply

# DevTools
flutter pub global activate devtools
devtools
```

---

## 🔑 Keyboard Shortcuts (VS Code)

| Action | macOS | Windows/Linux |
|--------|-------|--------------|
| Hot Reload | `⌘ S` | `Ctrl + S` |
| Hot Restart | `⇧ ⌘ F5` | `Shift + Ctrl + F5` |
| Open Command Palette | `⇧ ⌘ P` | `Shift + Ctrl + P` |
| Quick Fix | `⌘ .` | `Ctrl + .` |
| Go to Definition | `F12` | `F12` |
| Find References | `⇧ F12` | `Shift + F12` |
| Wrap with Widget | `⇧ ⌘ P` → "Wrap" | `Shift + Ctrl + P` → "Wrap" |
| Extract Widget | `⇧ ⌘ P` → "Extract" | `Shift + Ctrl + P` → "Extract" |

---

[← Glossary](GLOSSARY.md) | [Back to README →](README.md)
