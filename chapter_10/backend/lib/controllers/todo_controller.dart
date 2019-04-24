import 'dart:async';

import 'package:backend/models/todo.dart';
import 'package:backend/services/todos.dart';

class TodoController {
  final Services services;
  List<Todo> todos;

  StreamController<bool> onSyncController = new StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  TodoController(this.services);

  Future<List<Todo>> fetchTodos() async {
    onSyncController.add(true);
    todos = await services.getTodos();
    new Timer(new Duration(seconds: 2), () {
      onSyncController.add(false);
    });
    return todos;
  }

  Future<Todo> updateTodo(Todo todo, bool isCompleted) async {
    todo.completed = isCompleted;
    return await services.updateTodo(todo);
  }
}
