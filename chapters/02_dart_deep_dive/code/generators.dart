// Chapter 02 — Generators Examples
// Run: dart run generators.dart

import 'dart:async';

// ─── Synchronous Generator (sync*) ────────────────────────

/// Generates natural numbers from 1 to [max]
Iterable<int> naturals(int max) sync* {
  for (var i = 1; i <= max; i++) {
    yield i;
  }
}

/// Generates powers of 2
Iterable<int> powersOfTwo(int count) sync* {
  int value = 1;
  for (var i = 0; i < count; i++) {
    yield value;
    value *= 2;
  }
}

/// Range generator (like Python's range)
Iterable<int> range(int start, int end, [int step = 1]) sync* {
  for (var i = start; i < end; i += step) {
    yield i;
  }
}

/// yield* delegation example
Iterable<int> combined() sync* {
  yield* range(1, 4);    // 1, 2, 3
  yield 100;             // 100
  yield* range(7, 10);   // 7, 8, 9
}

// ─── Asynchronous Generator (async*) ──────────────────────

/// Simulates fetching paginated data
Stream<List<String>> fetchPages(int totalPages) async* {
  for (var page = 1; page <= totalPages; page++) {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    yield List.generate(3, (i) => 'Page $page, Item ${i + 1}');
  }
}

/// Fibonacci stream
Stream<int> fibonacciStream() async* {
  int a = 0, b = 1;
  while (true) {
    yield a;
    final next = a + b;
    a = b;
    b = next;
  }
}

/// Timer ticks using async generator
Stream<String> timerTicks(int count, Duration interval) async* {
  for (var i = 1; i <= count; i++) {
    await Future.delayed(interval);
    yield 'Tick $i at ${DateTime.now().millisecondsSinceEpoch}';
  }
}

// ─── Main ─────────────────────────────────────────────────

Future<void> main() async {
  // 1. Sync generator — lazy evaluation
  print('=== Natural Numbers (1-10) ===');
  for (final n in naturals(10)) {
    print(n);
  }

  // 2. Powers of 2
  print('\n=== Powers of Two (8) ===');
  print(powersOfTwo(8).toList()); // [1, 2, 4, 8, 16, 32, 64, 128]

  // 3. Range
  print('\n=== Range(0, 20, 3) ===');
  print(range(0, 20, 3).toList()); // [0, 3, 6, 9, 12, 15, 18]

  // 4. Combined with yield*
  print('\n=== Combined (yield*) ===');
  print(combined().toList()); // [1, 2, 3, 100, 7, 8, 9]

  // 5. Lazy evaluation proof
  print('\n=== Lazy Evaluation ===');
  var count = 0;
  Iterable<int> tracked(int max) sync* {
    for (var i = 1; i <= max; i++) {
      count++;
      yield i;
    }
  }
  // Only takes 3 values, so generator runs just 3 times
  final firstThree = tracked(1000000).take(3).toList();
  print('First 3: $firstThree, Generator ran $count times');

  // 6. Async generator — paginated fetch
  print('\n=== Paginated Fetch ===');
  await for (final page in fetchPages(3)) {
    print('Got page: $page');
  }

  // 7. Fibonacci stream
  print('\n=== Fibonacci Stream (first 10) ===');
  await for (final fib in fibonacciStream().take(10)) {
    stdout.write('$fib ');
  }
  print('');

  // 8. Timer ticks
  print('\n=== Timer Ticks ===');
  await for (final tick in timerTicks(3, const Duration(milliseconds: 200))) {
    print(tick);
  }

  print('\nAll done! ✅');
}
