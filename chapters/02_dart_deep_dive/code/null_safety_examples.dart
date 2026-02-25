// Chapter 02 — Null Safety Examples
// Run: dart run null_safety_examples.dart

void main() {
  // 1. Non-nullable vs Nullable
  String name = 'Flutter';
  String? nickname; // null by default

  print('Name: $name');
  print('Nickname: ${nickname ?? "not set"}');

  // 2. Null-aware operators
  nickname ??= 'Darty'; // Assign if null
  print('Nickname after ??=: $nickname');

  // 3. Null-safe member access
  String? maybeNull;
  print('Length: ${maybeNull?.length}'); // null, no crash

  // 4. Flow analysis / type promotion
  void greet(String? input) {
    if (input == null) {
      print('No input');
      return;
    }
    // input is promoted to String here
    print('Hello ${input.toUpperCase()}');
  }

  greet(null);   // No input
  greet('dart'); // Hello DART

  // 5. Late variables
  late final String description;
  description = 'Initialized later';
  print(description);

  // 6. Safe divide
  double? safeDivide(int? a, int? b) {
    if (a == null || b == null || b == 0) return null;
    return a / b;
  }

  print('10 / 3 = ${safeDivide(10, 3)}');
  print('10 / 0 = ${safeDivide(10, 0)}');
  print('null / 3 = ${safeDivide(null, 3)}');
}
