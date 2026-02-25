# Chapter 11 — Testing: Summary

## Key Takeaways
1. **Pyramid**: 70% unit, 20% widget, 10% integration.
2. Unit tests: pure Dart, no Flutter framework. Widget tests: `tester.pumpWidget()`.
3. Always call `tester.pump()` after `tap()` to trigger rebuild.
4. **Mockito** + `@GenerateMocks` for dependency mocking.
5. **Golden tests** for pixel-perfect visual regression.
6. **bloc_test** provides `blocTest()` for clean BLoC testing.
7. **Riverpod** tests use `ProviderContainer` or `ProviderScope` overrides.
8. Test behavior (what user sees), not implementation details.
9. Target > 80% coverage. Use CI to enforce.

## Next: [Chapter 12 — Architecture & Patterns](../12_architecture_patterns/12_architecture_patterns.md)
