# Chapter 02 — Dart Deep Dive: Summary

## Key Takeaways

1. **Sound null safety** — Types are non-nullable by default. Use `?` for nullable.
2. **Dart 3 features** — Records, patterns, sealed classes, switch expressions transform how you write Dart.
3. **Async model** — Single-threaded event loop. Use `async/await` for I/O, `Isolate.run()` for CPU work.
4. **Streams** — Single-subscription (file, HTTP) vs Broadcast (events, sensors).
5. **Generators** — `sync*` for lazy Iterables, `async*` for Streams.
6. **OOP** — Mixins for code reuse, sealed classes for exhaustive matching, extension types for zero-cost wrappers.
7. **Result pattern** — Sealed type for explicit error handling without exceptions.
8. **`const` everywhere** — Compile-time constants are canonicalized, saving memory.
9. **Avoid `dynamic`** — Use proper types, generics, or `Object?`.
10. **Isolates** don't share memory — communicate via message passing.

## Next: [Chapter 03 — Flutter Basics](../03_flutter_basics/03_flutter_basics.md)
