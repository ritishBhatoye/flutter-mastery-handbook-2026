# Chapter 05 — Navigation & Routing: Summary

## Key Takeaways

1. Flutter navigation is **stack-based** — push adds, pop removes.
2. **Navigator 1.0** = imperative (push/pop). Simple but limited.
3. **Navigator 2.0** = declarative (list of Pages). Powerful but verbose.
4. **GoRouter** = recommended wrapper. Simple API, deep linking, type-safe.
5. `context.go()` replaces stack; `context.push()` adds to stack.
6. **ShellRoute** wraps child routes with shared layout (bottom nav, sidebar).
7. **StatefulShellRoute** preserves state per tab branch.
8. **Deep linking** requires platform config (AndroidManifest, Info.plist) + route matching.
9. **Auth guards** via GoRouter's `redirect` + `refreshListenable`.
10. Use `PopScope` (not deprecated `WillPopScope`) for back button handling.

## Next: [Chapter 06 — Networking & Data](../06_networking_data/06_networking_data.md)
