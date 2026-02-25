# Chapter 12 — Architecture & Patterns

> **Goal**: Learn and apply production-grade architecture patterns — Clean Architecture, MVVM, Repository pattern, DI, and modularization.

---

## Table of Contents

1. [Why Architecture Matters](#1-why-architecture-matters)
2. [Clean Architecture](#2-clean-architecture)
3. [MVVM Pattern](#3-mvvm-pattern)
4. [MVC Pattern](#4-mvc-pattern)
5. [Repository Pattern](#5-repository-pattern)
6. [Use Cases / Interactors](#6-use-cases--interactors)
7. [Dependency Injection](#7-dependency-injection)
8. [Modularization](#8-modularization)
9. [Feature-First vs Layer-First](#9-feature-first-vs-layer-first)
10. [Common Pitfalls](#10-common-pitfalls)
11. [Interview Questions](#11-interview-questions)
12. [Practice Exercises](#12-practice-exercises)
13. [Resources](#13-resources)

---

## 1. Why Architecture Matters

```
Without Architecture        With Architecture
┌───────────────────┐       ┌───────────────────┐
│                   │       │   UI Layer         │
│  Everything in    │       ├───────────────────┤
│  one file /       │       │   Domain Layer     │
│  spaghetti        │       ├───────────────────┤
│  code             │       │   Data Layer       │
│                   │       └───────────────────┘
│  • Untestable     │       • Testable
│  • Rigid          │       • Flexible
│  • Hard to read   │       • Maintainable
│  • Can't scale    │       • Scales with team
└───────────────────┘       └───────────────────┘
```

---

## 2. Clean Architecture

Uncle Bob's Clean Architecture adapted for Flutter.

```
┌─────────────────────────────────────────────────────┐
│                   Clean Architecture                 │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │             Presentation Layer               │   │
│  │  • Widgets / Pages                          │   │
│  │  • State Management (Bloc, Riverpod)        │   │
│  │  • ViewModels                               │   │
│  └──────────────────┬──────────────────────────┘   │
│                     │ depends on                    │
│  ┌──────────────────▼──────────────────────────┐   │
│  │               Domain Layer                   │   │
│  │  • Entities (pure Dart classes)             │   │
│  │  • Use Cases / Interactors                  │   │
│  │  • Repository Interfaces                    │   │
│  │  • NO dependencies on Flutter/external pkgs │   │
│  └──────────────────┬──────────────────────────┘   │
│                     │ depends on                    │
│  ┌──────────────────▼──────────────────────────┐   │
│  │                Data Layer                    │   │
│  │  • Repository Implementations               │   │
│  │  • Data Sources (Remote, Local)             │   │
│  │  • DTOs / Models (JSON mapping)             │   │
│  │  • API clients, DB access                   │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  Dependency Rule: Inner layers know NOTHING about   │
│  outer layers. Domain is pure Dart.                 │
└─────────────────────────────────────────────────────┘
```

### Directory Structure

```
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   └── usecases/
│       └── usecase.dart           # Base UseCase interface
│
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── auth_remote_datasource.dart
│       │   │   └── auth_local_datasource.dart
│       │   ├── models/
│       │   │   └── user_model.dart       # DTO with fromJson/toJson
│       │   └── repositories/
│       │       └── auth_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user.dart             # Pure Dart, no dependencies
│       │   ├── repositories/
│       │   │   └── auth_repository.dart  # Abstract interface
│       │   └── usecases/
│       │       ├── login.dart
│       │       ├── logout.dart
│       │       └── get_current_user.dart
│       │
│       └── presentation/
│           ├── bloc/
│           │   ├── auth_bloc.dart
│           │   ├── auth_event.dart
│           │   └── auth_state.dart
│           ├── pages/
│           │   ├── login_page.dart
│           │   └── register_page.dart
│           └── widgets/
│               └── login_form.dart
│
├── injection_container.dart          # DI setup
└── main.dart
```

### Code Example

```dart
// ─── Domain Entity ──────────────────────────────
// domain/entities/user.dart — NO dependencies
class User {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});
}

// ─── Domain Repository Interface ─────────────────
// domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> logout();
}

// ─── Domain Use Case ─────────────────────────────
// domain/usecases/login.dart
class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<Either<Failure, User>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
}

// ─── Data Model (DTO) ────────────────────────────
// data/models/user_model.dart
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

// ─── Data Repository Implementation ──────────────
// data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final user = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}

// ─── Presentation Bloc ───────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    });
  }
}
```

---

## 3. MVVM Pattern

```
┌────────┐    observes    ┌───────────┐    calls    ┌───────┐
│  View  │ ◀──────────── │ ViewModel │ ──────────▶ │ Model │
│ (Page) │               │           │             │(Data) │
│        │  user action  │ • State   │             │       │
│        │ ─────────────▶│ • Logic   │             │       │
│        │               │ • Commands│             │       │
└────────┘               └───────────┘             └───────┘
```

```dart
// ViewModel using ChangeNotifier
class UserProfileViewModel extends ChangeNotifier {
  final UserRepository _repo;

  UserProfileViewModel(this._repo);

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repo.getUser(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## 4. MVC Pattern

```
┌────────────┐  user action  ┌────────────┐
│   View     │ ─────────────▶│ Controller │
│ (Widgets)  │               │            │
│            │   updates     │  updates   │
│            │ ◀─────────────│ ─────────▶ │
└────────────┘               └────────────┘
                                   │
                              ┌────▼───┐
                              │ Model  │
                              └────────┘
```

Flutter doesn't naturally enforce MVC. MVVM or Clean Architecture with Bloc/Riverpod is preferred.

---

## 5. Repository Pattern

The bridge between domain and data layers.

```dart
// Abstract — in domain layer
abstract class ProductRepository {
  Future<List<Product>> getProducts({int page = 1});
  Future<Product> getProduct(String id);
  Future<void> addToFavorites(String productId);
}

// Implementation — in data layer
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;
  final NetworkInfo _network;

  ProductRepositoryImpl(this._remote, this._local, this._network);

  @override
  Future<List<Product>> getProducts({int page = 1}) async {
    if (await _network.isConnected) {
      try {
        final products = await _remote.getProducts(page: page);
        await _local.cacheProducts(products);
        return products;
      } catch (e) {
        return _local.getCachedProducts();
      }
    } else {
      return _local.getCachedProducts();
    }
  }

  @override
  Future<Product> getProduct(String id) async {
    return _remote.getProduct(id);
  }

  @override
  Future<void> addToFavorites(String productId) async {
    await _remote.addToFavorites(productId);
    await _local.addToFavorites(productId);
  }
}
```

---

## 6. Use Cases / Interactors

Each use case represents a single business action.

```dart
// Base interface
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}

// Concrete use cases
class GetProducts implements UseCase<List<Product>, GetProductsParams> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) async {
    try {
      final products = await repository.getProducts(page: params.page);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class GetProductsParams {
  final int page;
  const GetProductsParams({this.page = 1});
}
```

---

## 7. Dependency Injection

### get_it (Service Locator)

```yaml
dependencies:
  get_it: ^7.7.0
  injectable: ^2.4.0

dev_dependencies:
  injectable_generator: ^2.6.0
  build_runner: ^2.4.0
```

```dart
// injection_container.dart
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void init() {
  // Blocs
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl()),
  );

  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}

// Usage
void main() {
  init();
  runApp(BlocProvider(
    create: (_) => sl<AuthBloc>(),
    child: const MyApp(),
  ));
}
```

### Riverpod as DI

```dart
// Riverpod providers ARE dependency injection
final dioProvider = Provider<Dio>((ref) => Dio(BaseOptions(baseUrl: apiUrl)));

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(client: ref.watch(dioProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepoProvider));
});

final authBlocProvider = Provider<AuthBloc>((ref) {
  return AuthBloc(loginUseCase: ref.watch(loginUseCaseProvider));
});
```

---

## 8. Modularization

### Monorepo with Melos

```yaml
# melos.yaml
name: my_app
packages:
  - apps/*
  - packages/*

# Structure:
# my_app/
# ├── apps/
# │   ├── customer_app/
# │   └── admin_app/
# └── packages/
#     ├── core/             # Shared utilities
#     ├── design_system/    # UI components
#     ├── auth/             # Auth feature
#     ├── payments/         # Payment feature
#     └── analytics/        # Analytics feature
```

### Benefits

```
┌──────────────────────────────────────────┐
│  Modularization Benefits                  │
│                                          │
│  ✅ Independent feature development      │
│  ✅ Faster build times (partial rebuild) │
│  ✅ Clear ownership boundaries            │
│  ✅ Reuse across multiple apps           │
│  ✅ Parallel team development            │
│  ✅ Better testability (isolated)        │
└──────────────────────────────────────────┘
```

---

## 9. Feature-First vs Layer-First

```
Feature-First (Recommended)       Layer-First
lib/                               lib/
├── features/                      ├── models/
│   ├── auth/                      │   ├── user.dart
│   │   ├── data/                  │   ├── product.dart
│   │   ├── domain/                │   └── order.dart
│   │   └── presentation/         ├── repositories/
│   ├── products/                  │   ├── auth_repo.dart
│   └── orders/                    │   ├── product_repo.dart
├── core/                          │   └── order_repo.dart
└── main.dart                      ├── screens/
                                   │   ├── login.dart
                                   │   └── products.dart
                                   └── main.dart

Feature-First:                     Layer-First:
✅ Scales with features           ✅ Simple for small apps
✅ Clear feature boundaries       ❌ Models mixed together
✅ Easy to delete features        ❌ Hard to find related code
❌ Some code duplication          ❌ Doesn't scale
```

> **2026 Recommendation**: Feature-first with Clean Architecture layers within each feature.

---

## 10. Common Pitfalls

### ❌ Over-Architecture
Don't apply Clean Architecture to a todo app. Match complexity to project size.

### ❌ Domain Depending on Data Layer
The domain layer must NEVER import Flutter, Dio, or any external package.

### ❌ Skipping the Repository Interface
Always define an abstract interface in domain — concrete in data. This enables testing and swapping implementations.

---

## 11. Interview Questions

### Q1: Explain Clean Architecture in Flutter.
**A**: Three layers — Presentation (UI + state management), Domain (entities, use cases, repository interfaces — pure Dart, no framework dependencies), Data (repository implementations, data sources, DTOs). The dependency rule flows inward: Presentation → Domain ← Data. Domain knows nothing about Presentation or Data.

### Q2: What is the Repository pattern?
**A**: A pattern that abstracts data access behind an interface. The domain layer defines what data it needs (interface). The data layer implements how to get it (API, database, cache). This allows swapping data sources without changing business logic and enables easy testing with mock repositories.

### Q3: Feature-first vs Layer-first — which is better?
**A**: Feature-first for apps with multiple features and growing teams — each feature is a self-contained module with its own layers. Layer-first for small apps where the overhead of feature modules isn't justified. Feature-first scales better and is the 2026 recommendation.

### Q4: How does DI work in Flutter?
**A**: DI provides dependencies from outside rather than creating them internally. `get_it` is a service locator — register instances, resolve them later. Riverpod providers naturally act as DI — each provider declares dependencies via `ref.watch()`. DI enables testability (inject mocks) and flexibility (swap implementations).

---

## 12. Practice Exercises

### Exercise 1: Clean Architecture
Refactor a flat "all-in-one" todo app into Clean Architecture with three layers.

### Exercise 2: DI Setup
Set up get_it DI for an app with: AuthBloc → LoginUseCase → AuthRepository → RemoteDataSource + LocalDataSource.

### Exercise 3: Modular Feature
Extract the "auth" feature into a separate Dart package that can be shared across two apps.

---

## 13. Resources

- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture)
- [Clean Architecture — Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [get_it Package](https://pub.dev/packages/get_it)
- [Melos Monorepo](https://melos.invertase.dev/)

---

[← Previous: Testing](../11_testing/11_testing.md) | [Next: Real Projects →](../13_real_projects/13_real_projects.md) | [Back to README](../../README.md)
