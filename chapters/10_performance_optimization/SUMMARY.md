# Chapter 10 — Performance: Summary

## Key Takeaways
1. Pipeline: Build → Layout → Paint → Composite → Rasterize. Target: 16ms/frame.
2. **Impeller** pre-compiles shaders at build time — no first-frame jank.
3. Use `const` everywhere. Split large `build()` into separate widget classes.
4. **RepaintBoundary** isolates paint to a layer — use for animated widgets.
5. `ListView.builder` + `itemExtent` for long lists. Never use `ListView` with many children.
6. Specify `cacheWidth`/`cacheHeight` for network images.
7. Profile in `--profile` mode, never debug mode.
8. Move heavy work (JSON, image) to `Isolate.run`.
9. `--split-debug-info` + `--obfuscate` + `--tree-shake-icons` for release.

## Next: [Chapter 11 — Testing](../11_testing/11_testing.md)
