import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo_item.dart';

class TodoService {
  static const String _key = 'todos';

  Future<List<TodoItem>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString(_key);
    if (todosJson != null) {
      final List<dynamic> decoded = json.decode(todosJson);
      return decoded.map((item) => TodoItem.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> saveTodos(List<TodoItem> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = json.encode(todos.map((todo) => todo.toJson()).toList());
    await prefs.setString(_key, todosJson);
  }
}

