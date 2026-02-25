# Chapter 07 — Local Storage: Summary

## Key Takeaways
1. **SharedPreferences** = simple key-value for primitives (settings, flags). NOT encrypted.
2. **Hive** = fast NoSQL, pure Dart, custom objects, encryption, reactive. Great for caching.
3. **Drift** = type-safe SQL with code gen, reactive streams, migrations. For relational data.
4. **flutter_secure_storage** for sensitive data (tokens, passwords).
5. **Stale-while-revalidate** = best UX caching pattern (render cache, fetch fresh, update).
6. Always handle **migrations** when changing schema versions.
7. Move heavy DB operations off the main isolate.

## Next: [Chapter 08 — Animations](../08_animations/08_animations.md)
