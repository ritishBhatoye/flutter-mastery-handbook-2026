# Chapter 09 — Platform Integration: Summary

## Key Takeaways
1. **MethodChannel** = one-shot request/response. **EventChannel** = continuous stream.
2. **Pigeon** generates type-safe channel code — no stringly-typed names.
3. Always handle `PlatformException` and `MissingPluginException`.
4. iOS requires `NSUsageDescription` keys in Info.plist for every permission.
5. Android permissions go in `AndroidManifest.xml`.
6. **Federated plugins** split into app-facing, interface, and platform-specific packages.
7. Channel calls on Android must be on the main thread.

## Next: [Chapter 10 — Performance](../10_performance_optimization/10_performance_optimization.md)
