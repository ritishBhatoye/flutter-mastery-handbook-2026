# Chapter 08 — Animations: Summary

## Key Takeaways
1. **Implicit** → simple (AnimatedContainer). **Explicit** → control (AnimationController).
2. Pass `child` to `AnimatedBuilder` to avoid rebuilding the subtree every frame.
3. `vsync` ties animation to screen refresh rate; use `SingleTickerProviderStateMixin`.
4. **Physics**: SpringSimulation, GravitySimulation for natural motion.
5. **Hero**: Same `tag` on both screens, framework handles the flight overlay.
6. **Stagger**: One controller, multiple `Interval` curves for choreographed sequences.
7. **Lottie** for After Effects JSON. **Rive** for interactive state machine animations.
8. Always **dispose** AnimationController.
9. AnimatedSwitcher needs a unique **Key** to detect widget change.

## Next: [Chapter 09 — Platform Integration](../09_platform_integration/09_platform_integration.md)
