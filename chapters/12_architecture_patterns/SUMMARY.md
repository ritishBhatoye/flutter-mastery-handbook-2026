# Chapter 12 — Architecture & Patterns: Summary

## Key Takeaways
1. **Clean Architecture**: Presentation → Domain ← Data. Domain is pure Dart, no dependencies.
2. **Repository pattern**: Abstract interface in domain, implementation in data.
3. **Use Cases**: One class = one business action. Accepts params, returns `Either<Failure, T>`.
4. **DI**: `get_it` (service locator) or Riverpod providers. Never `new` up deps inside classes.
5. **Feature-first** > Layer-first for scaling. Each feature has its own data/domain/presentation.
6. **Modularization** with Melos monorepo for multi-app sharing and faster builds.
7. Don't over-architect small apps. Match complexity to project size.

## Next: [Chapter 13 — Real Projects](../13_real_projects/13_real_projects.md)
