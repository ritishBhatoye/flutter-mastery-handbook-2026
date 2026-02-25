# Chapter 06 — Networking & Data

> **Goal**: Master HTTP networking, REST/GraphQL APIs, WebSockets, authentication, and secure data handling in Flutter.

---

## Table of Contents

1. [HTTP Basics](#1-http-basics)
2. [Dio — Advanced HTTP Client](#2-dio--advanced-http-client)
3. [REST API Integration](#3-rest-api-integration)
4. [JSON Serialization](#4-json-serialization)
5. [GraphQL](#5-graphql)
6. [WebSockets](#6-websockets)
7. [Authentication](#7-authentication)
8. [Secure Storage](#8-secure-storage)
9. [Certificate Pinning](#9-certificate-pinning)
10. [Offline-First Patterns](#10-offline-first-patterns)
11. [Common Pitfalls](#11-common-pitfalls)
12. [Interview Questions](#12-interview-questions)
13. [Practice Exercises](#13-practice-exercises)
14. [Resources](#14-resources)

---

## 1. HTTP Basics

```yaml
dependencies:
  http: ^1.2.0
```

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// GET
Future<List<User>> fetchUsers() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/users'),
    headers: {'Accept': 'application/json'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => User.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load users: ${response.statusCode}');
  }
}

// POST
Future<User> createUser(String name, String email) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': name, 'email': email}),
  );

  if (response.statusCode == 201) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create user');
  }
}

// PUT, DELETE, PATCH follow the same pattern
```

---

## 2. Dio — Advanced HTTP Client

```yaml
dependencies:
  dio: ^5.4.0
```

### Setup with Interceptors

```dart
import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl, String? token}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));

    // Logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    // Auth token refresh interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add fresh token before each request
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired — refresh and retry
          final newToken = await _refreshToken();
          if (newToken != null) {
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          }
        }
        handler.next(error);
      },
    ));

    // Retry interceptor
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
      ],
    ));
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? params}) {
    return _dio.get(path, queryParameters: params);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete(path);
  }
}
```

### File Upload

```dart
Future<void> uploadImage(String filePath) async {
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      filePath,
      filename: 'avatar.jpg',
    ),
    'type': 'profile',
  });

  await _dio.post('/upload', data: formData,
    onSendProgress: (sent, total) {
      final progress = (sent / total * 100).toStringAsFixed(1);
      print('Upload: $progress%');
    },
  );
}
```

### Cancellation

```dart
final cancelToken = CancelToken();

// Start request
_dio.get('/large-data', cancelToken: cancelToken);

// Cancel it
cancelToken.cancel('User navigated away');
```

---

## 3. REST API Integration

### Repository Pattern

```dart
abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User> getUser(int id);
  Future<User> createUser(UserRequest request);
  Future<User> updateUser(int id, UserRequest request);
  Future<void> deleteUser(int id);
}

class RemoteUserRepository implements UserRepository {
  final ApiClient _api;

  RemoteUserRepository(this._api);

  @override
  Future<List<User>> getUsers() async {
    final response = await _api.get('/users');
    return (response.data as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  @override
  Future<User> getUser(int id) async {
    final response = await _api.get('/users/$id');
    return User.fromJson(response.data);
  }

  @override
  Future<User> createUser(UserRequest request) async {
    final response = await _api.post('/users', data: request.toJson());
    return User.fromJson(response.data);
  }

  @override
  Future<User> updateUser(int id, UserRequest request) async {
    final response = await _api.put('/users/$id', data: request.toJson());
    return User.fromJson(response.data);
  }

  @override
  Future<void> deleteUser(int id) async {
    await _api.delete('/users/$id');
  }
}
```

---

## 4. JSON Serialization

### Manual

```dart
class User {
  final int id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
}
```

### Code Generation (Recommended)

```yaml
dependencies:
  json_annotation: ^4.9.0
  freezed_annotation: ^2.4.0

dev_dependencies:
  json_serializable: ^6.8.0
  freezed: ^2.5.0
  build_runner: ^2.4.0
```

```dart
// With freezed (immutable + JSON + copyWith + equality)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String name,
    required String email,
    @Default('') String bio,
    DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// Run: dart run build_runner build --delete-conflicting-outputs
```

---

## 5. GraphQL

```yaml
dependencies:
  graphql_flutter: ^5.1.0
```

```dart
final client = GraphQLClient(
  link: HttpLink('https://api.example.com/graphql'),
  cache: GraphQLCache(),
);

// Query
const getUserQuery = r'''
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
      posts {
        id
        title
      }
    }
  }
''';

// In widget
Query(
  options: QueryOptions(
    document: gql(getUserQuery),
    variables: {'id': '1'},
  ),
  builder: (result, {fetchMore, refetch}) {
    if (result.isLoading) return const CircularProgressIndicator();
    if (result.hasException) return Text('Error: ${result.exception}');

    final user = result.data!['user'];
    return Text('Name: ${user['name']}');
  },
)
```

---

## 6. WebSockets

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  late final WebSocketChannel _channel;

  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  Stream<dynamic> get messages => _channel.stream;

  void sendMessage(String message) {
    _channel.sink.add(jsonEncode({'type': 'message', 'text': message}));
  }

  void dispose() {
    _channel.sink.close();
  }
}

// Usage in widget
StreamBuilder(
  stream: chatService.messages,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final message = jsonDecode(snapshot.data);
      return Text(message['text']);
    }
    return const CircularProgressIndicator();
  },
)
```

---

## 7. Authentication

### JWT Flow

```
┌────────┐    1. Login (email/pass)    ┌────────┐
│ Client │ ───────────────────────────▶│ Server │
│        │ ◀───────────────────────────│        │
│        │    2. Access + Refresh Token │        │
│        │                             │        │
│        │    3. API call + Bearer token│        │
│        │ ───────────────────────────▶│        │
│        │ ◀───────────────────────────│        │
│        │    4. Protected data        │        │
│        │                             │        │
│        │    5. 401 Unauthorized       │        │
│        │ ◀───────────────────────────│        │
│        │    6. Refresh token request  │        │
│        │ ───────────────────────────▶│        │
│        │ ◀───────────────────────────│        │
│        │    7. New access token       │        │
└────────┘                             └────────┘
```

### Firebase Auth

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();
}
```

---

## 8. Secure Storage

```yaml
dependencies:
  flutter_secure_storage: ^9.2.0
```

```dart
class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

---

## 9. Certificate Pinning

```dart
// Using Dio with certificate pinning
SecurityContext createSecurityContext() {
  final context = SecurityContext();
  // Add trusted certificate
  context.setTrustedCertificatesBytes(certificateBytes);
  return context;
}

final dio = Dio()
  ..httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient(context: createSecurityContext());
      client.badCertificateCallback = (cert, host, port) => false;
      return client;
    },
  );
```

---

## 10. Offline-First Patterns

```dart
class OfflineFirstRepository<T> {
  final RemoteDataSource<T> _remote;
  final LocalDataSource<T> _local;

  OfflineFirstRepository(this._remote, this._local);

  Future<List<T>> getItems() async {
    try {
      // Try network first
      final items = await _remote.fetchAll();
      // Cache locally
      await _local.saveAll(items);
      return items;
    } catch (e) {
      // Fallback to cache
      return _local.getAll();
    }
  }

  Future<void> createItem(T item) async {
    // Save locally immediately
    await _local.save(item);
    try {
      // Sync to server
      await _remote.create(item);
    } catch (e) {
      // Queue for later sync
      await _local.markPendingSync(item);
    }
  }
}
```

---

## 11. Common Pitfalls

### ❌ Not Handling Timeouts
```dart
// Always set timeouts
Dio(BaseOptions(
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 15),
));
```

### ❌ Hardcoding API URLs
```dart
// Use environment config
class AppConfig {
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
}
// Run: flutter run --dart-define=API_URL=https://api.prod.com
```

### ❌ Not Cancelling Requests on Screen Dispose
```dart
final _cancelToken = CancelToken();

@override
void dispose() {
  _cancelToken.cancel();
  super.dispose();
}
```

---

## 12. Interview Questions

### Q1: REST vs GraphQL — when to use which?
**A**: REST is simpler, widely supported, and cache-friendly (HTTP caching). Use for standard CRUD with stable schemas. GraphQL prevents over/under-fetching (client specifies exact fields needed), has a typed schema, and is ideal for complex, nested data with varying client needs. Use GraphQL when mobile clients need flexibility or multiple resources per request.

### Q2: How do you handle token refresh in Flutter?
**A**: Use a Dio interceptor that catches 401 responses, calls the refresh endpoint with the refresh token, saves the new access token, and retries the original request. Use a mutex/lock to prevent concurrent refresh requests. If refresh fails, log the user out.

### Q3: What is certificate pinning and why use it?
**A**: Certificate pinning validates the server's SSL certificate against a known copy embedded in the app. Prevents MITM attacks even if a compromised CA issues a fake certificate. Important for banking, health, and high-security apps. Downside: need to update the app when certificates rotate.

### Q4: Explain the offline-first pattern.
**A**: Try server first, cache results locally. On network failure, serve from cache. On writes, save locally immediately, queue for server sync. Provide background sync when connectivity returns. This ensures the app works offline and feels fast. Libraries: Drift, Hive for local storage.

---

## 13. Practice Exercises

### Exercise 1: News Reader
Build a news app that fetches from a public API (NewsAPI), displays articles in a list, with pull-to-refresh and offline caching.

### Exercise 2: Auth Flow
Implement email/password login with JWT token storage, auto-refresh, and secure storage.

### Exercise 3: Chat with WebSockets
Build a simple chat UI connected to a WebSocket echo server (`wss://echo.websocket.org`).

---

## 14. Resources

- [Dio Package](https://pub.dev/packages/dio)
- [Flutter HTTP Cookbook](https://docs.flutter.dev/cookbook/networking)
- [graphql_flutter](https://pub.dev/packages/graphql_flutter)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

---

[← Previous: Navigation](../05_navigation_routing/05_navigation_routing.md) | [Next: Local Storage →](../07_local_storage/07_local_storage.md) | [Back to README](../../README.md)
