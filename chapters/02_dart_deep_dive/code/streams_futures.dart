// Chapter 02 — Streams & Futures Examples
// Run: dart run streams_futures.dart

import 'dart:async';

// ─── Futures ──────────────────────────────────────────────

Future<String> fetchUser() async {
  print('[fetchUser] Starting...');
  await Future.delayed(const Duration(milliseconds: 500));
  print('[fetchUser] Done!');
  return 'Alice';
}

Future<int> fetchAge() async {
  print('[fetchAge] Starting...');
  await Future.delayed(const Duration(milliseconds: 300));
  print('[fetchAge] Done!');
  return 28;
}

// ─── Streams ──────────────────────────────────────────────

Stream<int> countStream(int max) async* {
  for (var i = 1; i <= max; i++) {
    await Future.delayed(const Duration(milliseconds: 200));
    yield i;
  }
}

Stream<int> fibonacci() async* {
  int a = 0, b = 1;
  while (true) {
    yield a;
    final next = a + b;
    a = b;
    b = next;
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

// ─── StreamController Example ─────────────────────────────

Future<void> streamControllerDemo() async {
  print('\n--- StreamController Demo ---');
  final controller = StreamController<String>();

  // Listen
  controller.stream.listen(
    (data) => print('Received: $data'),
    onDone: () => print('Stream closed'),
  );

  // Add data
  controller.add('Hello');
  controller.add('World');
  controller.add('Dart Streams');

  // Close
  await controller.close();
}

// ─── Main ─────────────────────────────────────────────────

Future<void> main() async {
  // 1. Sequential futures
  print('=== Sequential Futures ===');
  final user = await fetchUser();
  final age = await fetchAge();
  print('User: $user, Age: $age');

  // 2. Parallel futures
  print('\n=== Parallel Futures ===');
  final results = await Future.wait([fetchUser(), fetchAge()]);
  print('Parallel results: $results');

  // 3. Simple stream
  print('\n=== Count Stream ===');
  await for (final count in countStream(5)) {
    print('Count: $count');
  }

  // 4. Fibonacci stream with take
  print('\n=== Fibonacci (first 8) ===');
  await for (final fib in fibonacci().take(8)) {
    print('Fib: $fib');
  }

  // 5. Stream transformations
  print('\n=== Stream Transformations ===');
  await countStream(10)
      .where((n) => n.isEven)
      .map((n) => 'Even: $n')
      .take(3)
      .forEach(print);

  // 6. StreamController
  await streamControllerDemo();

  print('\nAll done! ✅');
}
