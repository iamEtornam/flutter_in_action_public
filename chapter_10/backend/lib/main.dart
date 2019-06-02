import 'package:backend/controllers/todo_controller.dart';
import 'package:backend/services/todos.dart';
import 'package:backend/todo_page.dart';
import 'package:flutter/material.dart';

void main() async {
  var services = new HttpServices();
//  var services = new FirebaseServices();
  var controller = new TodoController(services);

  runApp(TodoApp(controller: controller));
}

class TodoApp extends StatelessWidget {
  final TodoController controller;

  TodoApp({this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoPage(controller: controller),
    );
  }
}
