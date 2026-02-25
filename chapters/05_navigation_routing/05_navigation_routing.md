# Chapter 05 — Navigation & Routing

> **Goal**: Master Flutter's navigation system — from basic push/pop to declarative routing, deep linking, and nested navigation.

---

## Table of Contents

1. [Navigation Fundamentals](#1-navigation-fundamentals)
2. [Navigator 1.0 (Imperative)](#2-navigator-10-imperative)
3. [Named Routes](#3-named-routes)
4. [Navigator 2.0 (Declarative)](#4-navigator-20-declarative)
5. [GoRouter](#5-gorouter)
6. [Deep Linking](#6-deep-linking)
7. [Nested Navigation](#7-nested-navigation)
8. [Route Guards & Authentication](#8-route-guards--authentication)
9. [Passing Data Between Screens](#9-passing-data-between-screens)
10. [Page Transitions](#10-page-transitions)
11. [Common Pitfalls](#11-common-pitfalls)
12. [Interview Questions](#12-interview-questions)
13. [Practice Exercises](#13-practice-exercises)
14. [Resources](#14-resources)

---

## 1. Navigation Fundamentals

Flutter navigation is **stack-based**:

```
┌──────────────────────────────────┐
│     Navigation Stack             │
│                                  │
│  ┌────────────┐  ← Top (active) │
│  │  Screen C  │                  │
│  ├────────────┤                  │
│  │  Screen B  │                  │
│  ├────────────┤                  │
│  │  Screen A  │  ← Bottom       │
│  └────────────┘                  │
│                                  │
│  push() → Add to top            │
│  pop()  → Remove from top       │
│  pushReplacement → Replace top   │
│  pushAndRemoveUntil → Clear stack│
└──────────────────────────────────┘
```

---

## 2. Navigator 1.0 (Imperative)

### Basic Push/Pop

```dart
// Push a new screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const DetailScreen(),
  ),
);

// Pop back
Navigator.of(context).pop();

// Pop with result
Navigator.of(context).pop('result_data');

// Push and receive result
final result = await Navigator.of(context).push<String>(
  MaterialPageRoute(builder: (context) => const SelectionScreen()),
);
print('Selected: $result');

// Push replacement (replaces current screen)
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => const HomeScreen()),
);

// Push and remove all previous routes
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) => const HomeScreen()),
  (route) => false, // Remove all
);

// Can pop? (check if there's a screen to go back to)
final canPop = Navigator.of(context).canPop();
```

### Shorthand Methods

```dart
// These are equivalent, shorter alternatives:
Navigator.push(context, MaterialPageRoute(builder: (_) => Screen()));
Navigator.pop(context);
Navigator.pushNamed(context, '/details');
```

---

## 3. Named Routes

```dart
// Define routes in MaterialApp
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => const HomeScreen(),
    '/details': (context) => const DetailScreen(),
    '/settings': (context) => const SettingsScreen(),
  },
  // Handle unknown routes
  onUnknownRoute: (settings) {
    return MaterialPageRoute(
      builder: (context) => const NotFoundScreen(),
    );
  },
)

// Navigate using route names
Navigator.pushNamed(context, '/details');

// Pass arguments
Navigator.pushNamed(
  context,
  '/details',
  arguments: {'id': 42, 'title': 'Product'},
);

// Retrieve arguments
class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return Text('ID: ${args['id']}');
  }
}

// onGenerateRoute — dynamic route handling
MaterialApp(
  onGenerateRoute: (settings) {
    if (settings.name == '/product') {
      final args = settings.arguments as Map;
      return MaterialPageRoute(
        builder: (context) => ProductScreen(id: args['id']),
      );
    }
    return null; // Falls to onUnknownRoute
  },
)
```

> ⚠️ Named routes are simple but limited. For production apps, use **GoRouter**.

---

## 4. Navigator 2.0 (Declarative)

Navigator 2.0 provides a declarative API — you specify **what** the stack should look like, not **how** to change it.

```dart
class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AppRoutePath _currentPath = AppRoutePath.home();

  @override
  AppRoutePath get currentConfiguration => _currentPath;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        const MaterialPage(
          key: ValueKey('home'),
          child: HomeScreen(),
        ),
        if (_currentPath.isDetail)
          MaterialPage(
            key: ValueKey('detail-${_currentPath.id}'),
            child: DetailScreen(id: _currentPath.id!),
          ),
      ],
      onDidRemovePage: (page) {
        _currentPath = AppRoutePath.home();
        notifyListeners();
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    _currentPath = configuration;
    notifyListeners();
  }
}
```

> 💡 Navigator 2.0 is powerful but verbose. That's why **GoRouter** exists.

---

## 5. GoRouter

The **recommended** routing package for Flutter (2026). Built on Navigator 2.0 with a simple API.

### Setup
```yaml
dependencies:
  go_router: ^14.0.0
```

### Basic Configuration

```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        // Nested route: /products
        GoRoute(
          path: 'products',
          name: 'products',
          builder: (context, state) => const ProductsScreen(),
          routes: [
            // /products/:id
            GoRoute(
              path: ':id',
              name: 'product-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ProductDetailScreen(id: id);
              },
            ),
          ],
        ),
        // /settings
        GoRoute(
          path: 'settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => NotFoundScreen(error: state.error),
);

// Use in MaterialApp
MaterialApp.router(
  routerConfig: router,
)
```

### Navigation

```dart
// Go to a route (replaces current stack)
context.go('/products/42');

// Push a route (adds to stack)
context.push('/products/42');

// Go named
context.goNamed('product-detail', pathParameters: {'id': '42'});

// Push named
context.pushNamed('settings');

// Pop
context.pop();

// Replace
context.pushReplacement('/home');

// Query parameters
context.goNamed(
  'products',
  queryParameters: {'sort': 'price', 'category': 'electronics'},
);
// URL: /products?sort=price&category=electronics

// Read query params
final sort = state.uri.queryParameters['sort'];
```

### Shell Route (Tab / Sidebar Navigation)

```dart
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeTab(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchTab(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileTab(),
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateIndex(GoRouterState.of(context).uri.path),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/home');
            case 1: context.go('/search');
            case 2: context.go('/profile');
          }
        },
      ),
    );
  }

  int _calculateIndex(String path) {
    if (path.startsWith('/search')) return 1;
    if (path.startsWith('/profile')) return 2;
    return 0;
  }
}
```

---

## 6. Deep Linking

Deep linking allows opening your app to a specific screen via a URL.

### GoRouter Deep Link Setup

GoRouter handles deep linking automatically. Just configure routes with proper paths.

### Android Setup

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<activity>
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
      android:scheme="https"
      android:host="myapp.com"
      android:pathPrefix="/products" />
  </intent-filter>
</activity>
```

### iOS Setup

```xml
<!-- ios/Runner/Info.plist -->
<key>FlutterDeepLinkingEnabled</key>
<true/>

<!-- ios/Runner/Runner.entitlements -->
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:myapp.com</string>
</array>
```

### Web

GoRouter uses the browser URL bar natively — deep linking just works!

---

## 7. Nested Navigation

```dart
// StatefulShellRoute for independent navigation stacks per tab
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return ScaffoldWithNavBar(navigationShell: navigationShell);
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'detail/:id',
              builder: (context, state) => DetailScreen(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
)
```

---

## 8. Route Guards & Authentication

```dart
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = authNotifier.isLoggedIn;
    final isLoginRoute = state.matchedLocation == '/login';

    // Not logged in and not on login page → redirect to login
    if (!isLoggedIn && !isLoginRoute) return '/login';

    // Logged in and on login page → redirect to home
    if (isLoggedIn && isLoginRoute) return '/';

    // No redirect needed
    return null;
  },
  refreshListenable: authNotifier, // Re-evaluate on auth changes
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/admin',
      builder: (_, __) => const AdminScreen(),
      redirect: (context, state) {
        // Per-route guard
        if (!authNotifier.isAdmin) return '/';
        return null;
      },
    ),
  ],
);
```

---

## 9. Passing Data Between Screens

```dart
// 1. Path parameters: /product/42
GoRoute(
  path: 'product/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ProductScreen(id: id);
  },
)

// 2. Query parameters: /search?q=flutter&page=1
GoRoute(
  path: 'search',
  builder: (context, state) {
    final query = state.uri.queryParameters['q'] ?? '';
    final page = int.tryParse(state.uri.queryParameters['page'] ?? '1') ?? 1;
    return SearchScreen(query: query, page: page);
  },
)

// 3. Extra data (not in URL — complex objects)
context.push('/details', extra: myProduct);

GoRoute(
  path: '/details',
  builder: (context, state) {
    final product = state.extra as Product;
    return DetailsScreen(product: product);
  },
)
```

---

## 10. Page Transitions

```dart
GoRoute(
  path: '/details',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const DetailsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  },
)

// Fade transition
CustomTransitionPage(
  child: screen,
  transitionsBuilder: (_, animation, __, child) {
    return FadeTransition(opacity: animation, child: child);
  },
)
```

---

## 11. Common Pitfalls

### ❌ Using Navigator 1.0 for Complex Apps
For anything beyond a few screens, use GoRouter. Named routes are hard to maintain.

### ❌ Not Handling Back Button on Android
```dart
// GoRouter handles this, but with Navigator 1.0:
WillPopScope( // Deprecated in Flutter 3.12+
  onWillPop: () async => false, // Prevent back
  child: ...
)

// Use PopScope instead (Flutter 3.12+)
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) {
    // Handle back button
  },
  child: ...
)
```

### ❌ Deep Link Not Working
- Ensure `FlutterDeepLinkingEnabled` is `true` in iOS Info.plist
- Verify AndroidManifest.xml intent filters
- Test with: `adb shell am start -d "https://myapp.com/products/42"`

---

## 12. Interview Questions

### Q1: What is the difference between Navigator 1.0 and 2.0?
**A**: Navigator 1.0 is imperative — you call `push()`, `pop()` to modify the stack. Navigator 2.0 is declarative — you specify the list of `Page` objects and the framework manages the actual navigation. Navigator 2.0 supports deep linking, web URL sync, and complex routing but is verbose. GoRouter wraps it with a simple API.

### Q2: What is `context.go()` vs `context.push()` in GoRouter?
**A**: `context.go()` navigates to a location by replacing the entire stack up to the new route (declarative). `context.push()` adds the route on top of the existing stack (imperative). Use `go` for top-level navigation; use `push` for detail screens you want to pop from.

### Q3: How does deep linking work in Flutter?
**A**: When the OS receives a URL (via browser, notification, or another app), it launches the Flutter app and forwards the URL. GoRouter parses the URL against route definitions and navigates to the matching screen. On web, it syncs with the browser address bar. Requires platform-specific config (AndroidManifest.xml, Info.plist/Entitlements).

### Q4: What is a ShellRoute?
**A**: A GoRouter construct that wraps child routes with a shared layout (e.g., `Scaffold` with bottom navigation bar). The shell stays in place while child content changes. `StatefulShellRoute` maintains separate navigation stacks per tab, preventing each branch from losing state.

### Q5: How do you implement authentication guards?
**A**: Use GoRouter's `redirect` callback. Check auth state on each navigation. If not logged in and not on login page, redirect to login. If logged in and on login page, redirect to home. Use `refreshListenable` to re-evaluate on auth state changes.

---

## 13. Practice Exercises

### Exercise 1: Tab Navigation
Build a 4-tab app (Home, Search, Cart, Profile) using GoRouter's `StatefulShellRoute`. Each tab should maintain its own navigation stack.

### Exercise 2: Auth Flow
Create a login flow with GoRouter: splash → login → home. Protect all routes except login and splash with an auth guard.

### Exercise 3: Deep Link Testing
Add deep link support so that `myapp://product/42` opens the product detail screen directly.

---

## 14. Resources

- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Navigation Guide](https://docs.flutter.dev/ui/navigation)
- [Deep Linking Cookbook](https://docs.flutter.dev/cookbook/navigation/set-up-app-links)
- [Navigation 2.0 — Understanding](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade)

---

[← Previous: State Management](../04_state_management/04_state_management.md) | [Next: Networking & Data →](../06_networking_data/06_networking_data.md) | [Back to README](../../README.md)
