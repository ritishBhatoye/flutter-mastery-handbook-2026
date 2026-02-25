# Chapter 07 — Local Storage

> **Goal**: Master local data persistence — from simple key-value storage to full SQL databases and caching strategies.

---

## Table of Contents

1. [Storage Options Overview](#1-storage-options-overview)
2. [SharedPreferences](#2-sharedpreferences)
3. [Hive](#3-hive)
4. [Drift (formerly Moor)](#4-drift-formerly-moor)
5. [File System Access](#5-file-system-access)
6. [Caching Strategies](#6-caching-strategies)
7. [Common Pitfalls](#7-common-pitfalls)
8. [Interview Questions](#8-interview-questions)
9. [Practice Exercises](#9-practice-exercises)
10. [Resources](#10-resources)

---

## 1. Storage Options Overview

```
┌──────────────────────┬──────────────┬──────────────┬────────────────┐
│ Feature              │ SharedPrefs  │ Hive         │ Drift          │
├──────────────────────┼──────────────┼──────────────┼────────────────┤
│ Type                 │ Key-value    │ NoSQL/KV     │ SQL (SQLite)   │
│ Data types           │ Primitives   │ Any (custom) │ Any (typed)    │
│ Query support        │ None         │ Limited      │ Full SQL       │
│ Relationships        │ None         │ Manual       │ Foreign keys   │
│ Performance          │ Fast (small) │ Very fast    │ Fast           │
│ Reactive             │ No           │ Yes          │ Yes (streams)  │
│ Encryption           │ No           │ Yes (AES)    │ Via plugin     │
│ Code generation      │ No           │ Optional     │ Yes            │
│ Best for             │ Preferences  │ Caching, KV  │ Complex data   │
└──────────────────────┴──────────────┴──────────────┴────────────────┘
```

---

## 2. SharedPreferences

Simple key-value storage for primitive types.

```yaml
dependencies:
  shared_preferences: ^2.3.0
```

```dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme mode
  bool get isDarkMode => _prefs.getBool('dark_mode') ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool('dark_mode', value);

  // Language
  String get locale => _prefs.getString('locale') ?? 'en';
  Future<void> setLocale(String value) => _prefs.setString('locale', value);

  // Onboarding
  bool get hasSeenOnboarding => _prefs.getBool('onboarding_complete') ?? false;
  Future<void> completeOnboarding() => _prefs.setBool('onboarding_complete', true);

  // Clear all
  Future<void> clear() => _prefs.clear();
}
```

### When to Use
- ✅ User preferences (theme, language, notification settings)
- ✅ Simple flags (first launch, onboarding complete)
- ❌ NOT for large datasets or complex objects
- ❌ NOT for sensitive data (not encrypted)

---

## 3. Hive

Fast, lightweight NoSQL database written in pure Dart.

```yaml
dependencies:
  hive: ^4.0.0
  hive_flutter: ^2.0.0

dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.4.0
```

```dart
import 'package:hive_flutter/hive_flutter.dart';

// 1. Define model with TypeAdapter
@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String content;

  @HiveField(2)
  late DateTime createdAt;

  @HiveField(3)
  late bool isPinned;
}

// 2. Initialize Hive
Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter()); // Generated
  await Hive.openBox<Note>('notes');
  runApp(const MyApp());
}

// 3. CRUD operations
class NoteRepository {
  final Box<Note> _box = Hive.box<Note>('notes');

  List<Note> getAll() => _box.values.toList();

  Note? get(int index) => _box.getAt(index);

  Future<void> add(Note note) => _box.add(note);

  Future<void> update(int index, Note note) => _box.putAt(index, note);

  Future<void> delete(int index) => _box.deleteAt(index);

  // Reactive — listen for changes
  ValueListenable<Box<Note>> get listenable => _box.listenable();
}

// 4. Reactive UI with ValueListenableBuilder
ValueListenableBuilder<Box<Note>>(
  valueListenable: noteRepo.listenable,
  builder: (context, box, _) {
    final notes = box.values.toList();
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(notes[index].title),
        subtitle: Text(notes[index].content),
      ),
    );
  },
)

// 5. Encryption
final encryptionKey = Hive.generateSecureKey();
await Hive.openBox('secrets', encryptionCipher: HiveAesCipher(encryptionKey));
```

---

## 4. Drift (formerly Moor)

Type-safe reactive SQL database for Dart/Flutter.

```yaml
dependencies:
  drift: ^2.16.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0

dev_dependencies:
  drift_dev: ^2.16.0
  build_runner: ^2.4.0
```

```dart
import 'package:drift/drift.dart';

part 'database.g.dart';

// Define tables
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get content => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
}

// Database class
@DriftDatabase(tables: [Todos, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Queries
  Future<List<Todo>> getAllTodos() => select(todos).get();

  Stream<List<Todo>> watchAllTodos() => select(todos).watch();

  Stream<List<Todo>> watchTodosByCategory(int categoryId) {
    return (select(todos)..where((t) => t.categoryId.equals(categoryId))).watch();
  }

  Future<int> insertTodo(TodosCompanion entry) => into(todos).insert(entry);

  Future<bool> updateTodo(Todo entry) => update(todos).replace(entry);

  Future<int> deleteTodo(int id) {
    return (delete(todos)..where((t) => t.id.equals(id))).go();
  }

  // Complex query with join
  Stream<List<TodoWithCategory>> watchTodosWithCategories() {
    final query = select(todos).join([
      leftOuterJoin(categories, categories.id.equalsExp(todos.categoryId)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TodoWithCategory(
          todo: row.readTable(todos),
          category: row.readTableOrNull(categories),
        );
      }).toList();
    });
  }

  // Migration
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(todos, todos.categoryId);
      }
    },
  );
}

class TodoWithCategory {
  final Todo todo;
  final Category? category;
  TodoWithCategory({required this.todo, this.category});
}
```

---

## 5. File System Access

```yaml
dependencies:
  path_provider: ^2.1.0
```

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.json');
  }

  Future<String> readFile() async {
    final file = await _localFile;
    if (await file.exists()) {
      return file.readAsString();
    }
    return '';
  }

  Future<File> writeFile(String content) async {
    final file = await _localFile;
    return file.writeAsString(content);
  }

  Future<void> deleteFile() async {
    final file = await _localFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
```

### Common Directories

```dart
// App-specific (cleared on uninstall)
getApplicationDocumentsDirectory(); // Documents
getApplicationSupportDirectory();   // Support files
getApplicationCacheDirectory();     // Cache (OS may clear)

// Shared
getTemporaryDirectory();            // Temp files
getExternalStorageDirectory();      // Android external (needs permission)
getDownloadsDirectory();            // Desktop downloads
```

---

## 6. Caching Strategies

```
┌──────────────────────────────────────────────────────┐
│              Caching Strategies                       │
├──────────────────┬───────────────────────────────────┤
│ Cache-First      │ Check cache → if miss → API       │
│                  │ Fast reads, may be stale           │
├──────────────────┼───────────────────────────────────┤
│ Network-First    │ Try API → if fail → cache          │
│                  │ Fresh data, slower                 │
├──────────────────┼───────────────────────────────────┤
│ Stale-While-     │ Return cache immediately →         │
│ Revalidate       │ fetch API → update cache → notify  │
│                  │ Best UX + fresh data               │
├──────────────────┼───────────────────────────────────┤
│ Time-Based       │ Cache for X minutes/hours          │
│ Expiry           │ Simple, predictable                │
└──────────────────┴───────────────────────────────────┘
```

### Stale-While-Revalidate Implementation

```dart
class CachedRepository<T> {
  final RemoteDataSource<T> _remote;
  final LocalCache<T> _cache;
  final Duration _maxAge;

  CachedRepository(this._remote, this._cache, {Duration? maxAge})
      : _maxAge = maxAge ?? const Duration(minutes: 5);

  Stream<List<T>> getItems() async* {
    // 1. Emit cached data immediately
    final cached = await _cache.getAll();
    if (cached.isNotEmpty) {
      yield cached;
    }

    // 2. Fetch fresh data
    try {
      final fresh = await _remote.fetchAll();
      await _cache.saveAll(fresh);
      await _cache.setLastFetchTime(DateTime.now());
      yield fresh;
    } catch (e) {
      // If cache was empty and network failed, rethrow
      if (cached.isEmpty) rethrow;
      // Otherwise, cached data was already emitted
    }
  }

  Future<bool> get isStale async {
    final lastFetch = await _cache.getLastFetchTime();
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch) > _maxAge;
  }
}
```

---

## 7. Common Pitfalls

### ❌ Storing Sensitive Data in SharedPreferences
SharedPreferences is NOT encrypted. Use `flutter_secure_storage` for tokens, passwords, PII.

### ❌ Not Closing Hive Boxes
```dart
// Close when app terminates
await Hive.close();
```

### ❌ Blocking the UI with Large DB Operations
```dart
// Move heavy DB work to an isolate
final largeData = await Isolate.run(() {
  return database.processLargeDataset();
});
```

### ❌ Not Handling Migration in Drift
Always implement `onUpgrade` in `MigrationStrategy` when changing schema.

---

## 8. Interview Questions

### Q1: SharedPreferences vs Hive vs Drift — when to use each?
**A**: SharedPreferences for simple key-value (settings, flags) — primitives only. Hive for fast NoSQL with custom objects, encryption, and reactive listeners — offline caching, user data. Drift for complex relational data with SQL queries, joins, migrations — structured app data, multi-table relationships.

### Q2: How does stale-while-revalidate work?
**A**: Return cached data immediately for fast UX, then fetch fresh data from the API in the background. When fresh data arrives, update the cache and emit the new data. User sees data instantly, then gets updated data seamlessly.

### Q3: How do you handle database migrations?
**A**: Increment `schemaVersion`. In `onUpgrade`, check `from` version and apply incremental changes (`addColumn`, `createTable`, `deleteColumn`). Test migrations with integration tests. For Drift, use `MigrationStrategy` with `onUpgrade`. Never drop and recreate in production.

---

## 9. Practice Exercises

### Exercise 1: Notes App with Hive
Build a notes app: create, read, update, delete notes. Store in Hive with a custom TypeAdapter.

### Exercise 2: Todo App with Drift
Build a todo app with categories. Use Drift for SQL storage with reactive streams.

### Exercise 3: Settings Page
Build a settings page with SharedPreferences: theme toggle, language selector, notification preferences.

---

## 10. Resources

- [SharedPreferences](https://pub.dev/packages/shared_preferences)
- [Hive](https://pub.dev/packages/hive)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [path_provider](https://pub.dev/packages/path_provider)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

---

[← Previous: Networking](../06_networking_data/06_networking_data.md) | [Next: Animations →](../08_animations/08_animations.md) | [Back to README](../../README.md)
