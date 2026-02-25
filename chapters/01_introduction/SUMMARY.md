# Chapter 01 — Introduction: Summary

## Key Takeaways

1. **Flutter** is Google's cross-platform UI toolkit using Dart, targeting 6 platforms from one codebase
2. **Impeller** is the default rendering engine in 2026 — eliminates shader jank
3. Flutter uses **three trees**: Widget (config) → Element (lifecycle) → RenderObject (layout/paint)
4. **Hot Reload** injects updated code preserving state; **Hot Restart** restarts from `main()`
5. Use `flutter doctor` to verify your setup — all checks should be green
6. VS Code with Flutter/Dart extensions is the recommended IDE
7. Every Flutter app starts with `runApp()` → `MaterialApp` → your widget tree
8. Always use `const` constructors where possible for performance
9. Set up linting early with `flutter_lints` package

## Prerequisites for Next Chapter
- Flutter SDK installed and `flutter doctor` passing
- An IDE configured (VS Code or Android Studio)
- A running emulator or physical device
- The counter app running successfully

## Next: [Chapter 02 — Dart Deep Dive](../02_dart_deep_dive/02_dart_deep_dive.md)
