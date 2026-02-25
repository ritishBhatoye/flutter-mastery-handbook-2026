# Chapter 04 — State Management: Summary

## Key Takeaways

1. **Ephemeral state** (local) → `setState()`. **App state** (shared) → state management solution.
2. **Provider** wraps InheritedWidget — simple, Google-recommended for small apps.
3. **Riverpod** (2026 favorite) — compile-safe, no BuildContext, excellent testability, auto-dispose.
4. **Bloc** — event-driven, highly traceable, best for large enterprise teams.
5. **GetX** — fast prototyping but weaker testability and conventions.
6. `context.watch()` rebuilds; `context.read()` doesn't.
7. `ref.watch()` in build, `ref.read()` in callbacks, `ref.listen()` for side effects.
8. In Bloc: Events → Bloc → States (unidirectional data flow).
9. Always use immutable state updates (new list, not mutate in place).
10. Use `Equatable` with Bloc to prevent unnecessary rebuilds.

## Next: [Chapter 05 — Navigation & Routing](../05_navigation_routing/05_navigation_routing.md)
