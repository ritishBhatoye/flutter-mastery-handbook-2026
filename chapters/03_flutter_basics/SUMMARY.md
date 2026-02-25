# Chapter 03 — Flutter Basics: Summary

## Key Takeaways

1. **Everything is a widget** — composition over inheritance
2. **StatelessWidget** = immutable config; **StatefulWidget** = mutable state with lifecycle
3. **Three trees**: Widget (cheap config) → Element (lifecycle) → RenderObject (layout + paint)
4. **Layout**: Constraints down, sizes up, parent positions child — single-pass O(N)
5. **Keys** are essential when reordering/removing same-type children
6. **BuildContext** = handle to Element position; used for ancestor lookups
7. **Slivers** enable advanced scroll effects in `CustomScrollView`
8. **Always dispose** controllers, subscriptions, observers in `dispose()`
9. **Check `mounted`** before calling `setState` in async callbacks
10. **LayoutBuilder** > **MediaQuery** for responsive layouts (fewer rebuilds)

## Next: [Chapter 04 — State Management](../04_state_management/04_state_management.md)
