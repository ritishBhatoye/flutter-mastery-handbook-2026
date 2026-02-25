// Chapter 04 — State Management Code Examples
// Counter app implemented with Riverpod (recommended 2026)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── State ────────────────────────────────────────

class TodoItem {
  final String id;
  final String title;
  final bool completed;

  const TodoItem({
    required this.id,
    required this.title,
    this.completed = false,
  });

  TodoItem copyWith({String? title, bool? completed}) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

// ─── Notifier ─────────────────────────────────────

class TodoNotifier extends Notifier<List<TodoItem>> {
  @override
  List<TodoItem> build() => [];

  void add(String title) {
    state = [
      ...state,
      TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
      ),
    ];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id) todo.copyWith(completed: !todo.completed)
        else todo,
    ];
  }

  void remove(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }
}

// ─── Providers ────────────────────────────────────

final todoProvider = NotifierProvider<TodoNotifier, List<TodoItem>>(
  TodoNotifier.new,
);

enum TodoFilter { all, active, completed }

final filterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

final filteredTodosProvider = Provider<List<TodoItem>>((ref) {
  final filter = ref.watch(filterProvider);
  final todos = ref.watch(todoProvider);

  return switch (filter) {
    TodoFilter.all       => todos,
    TodoFilter.active    => todos.where((t) => !t.completed).toList(),
    TodoFilter.completed => todos.where((t) => t.completed).toList(),
  };
});

// ─── UI ───────────────────────────────────────────

void main() {
  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod Todo',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodosProvider);
    final filter = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Todo'),
        actions: [
          SegmentedButton<TodoFilter>(
            segments: const [
              ButtonSegment(value: TodoFilter.all, label: Text('All')),
              ButtonSegment(value: TodoFilter.active, label: Text('Active')),
              ButtonSegment(value: TodoFilter.completed, label: Text('Done')),
            ],
            selected: {filter},
            onSelectionChanged: (selected) {
              ref.read(filterProvider.notifier).state = selected.first;
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            leading: Checkbox(
              value: todo.completed,
              onChanged: (_) => ref.read(todoProvider.notifier).toggle(todo.id),
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => ref.read(todoProvider.notifier).remove(todo.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'What needs to be done?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(todoProvider.notifier).add(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
