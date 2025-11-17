import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoItem {
  final String id;
  final String title;
  final String description;
  final bool isDone;

  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isDone': isDone,
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    isDone: json['isDone'],
  );

  TodoItem copyWith({String? title, String? description, bool? isDone}) => TodoItem(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    isDone: isDone ?? this.isDone,
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TodoItem> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksString = prefs.getString('tasks');
      
      if (tasksString != null) {
        final tasksJson = json.decode(tasksString) as List;
        setState(() {
          _tasks = tasksJson.map((json) => TodoItem.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = json.encode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksString);
  }

  void _addTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditTodoScreen()),
    );

    if (result != null && result is TodoItem) {
      setState(() {
        _tasks.add(result);
      });
      await _saveTasks();
    }
  }

  void _editTask(TodoItem task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTodoScreen(task: task)),
    );

    if (result != null) {
      if (result is TodoItem) {
        setState(() {
          final index = _tasks.indexWhere((t) => t.id == result.id);
          if (index != -1) _tasks[index] = result;
        });
        await _saveTasks();
      } else if (result == 'deleted') {
        _deleteTask(task);
      }
    }
  }

  void _deleteTask(TodoItem task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
    _saveTasks();
  }

  void _toggleTask(TodoItem task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(isDone: !task.isDone);
      }
    });
    _saveTasks();
  }

  List<TodoItem> get _filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.current:
        return _tasks.where((task) => !task.isDone).toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.isDone).toList();
    }
  }

  String get _filterTitle {
    switch (_currentFilter) {
      case TaskFilter.all:
        return 'Все задачи';
      case TaskFilter.current:
        return 'Текущие задачи';
      case TaskFilter.completed:
        return 'Выполненные задачи';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_filterTitle),
        actions: [
          PopupMenuButton<TaskFilter>(
            onSelected: (filter) => setState(() => _currentFilter = filter),
            itemBuilder: (context) => [
              const PopupMenuItem(value: TaskFilter.all, child: Text('Все')),
              const PopupMenuItem(value: TaskFilter.current, child: Text('Текущие')),
              const PopupMenuItem(value: TaskFilter.completed, child: Text('Выполненные')),
            ],
          ),
        ],
      ),
      body: _filteredTasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.task, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Нет задач',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentFilter == TaskFilter.all 
                      ? 'Добавьте первую задачу'
                      : 'Нет задач в этой категории',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: task.isDone
                          ? const TextStyle(
                              decoration: TextDecoration.lineThrough, 
                              color: Colors.grey
                            )
                          : null,
                    ),
                    subtitle: Text(
                      task.description.isEmpty ? 'Нет описания' : task.description,
                      style: task.isDone
                          ? const TextStyle(decoration: TextDecoration.lineThrough)
                          : null,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (value) => _toggleTask(task),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editTask(task),
                        ),
                      ],
                    ),
                    onTap: () => _editTask(task),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}

enum TaskFilter { all, current, completed }

class EditTodoScreen extends StatefulWidget {
  final TodoItem? task;
  const EditTodoScreen({this.task, super.key});

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Новая задача' : 'Редактировать'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название задачи',
                  border: OutlineInputBorder(),
                  hintText: 'Введите название задачи',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Введите название задачи' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание задачи',
                  border: OutlineInputBorder(),
                  hintText: 'Введите описание задачи (необязательно)',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                textAlignVertical: TextAlignVertical.top, // Выравнивание по верху
                minLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Сохранить'),
              ),
              if (widget.task != null) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _showDeleteDialog,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Удалить задачу'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = TodoItem(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        isDone: widget.task?.isDone ?? false,
      );
      Navigator.pop(context, task);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, 'deleted');
            },
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}