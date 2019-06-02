import 'package:backend/controllers/todo_controller.dart';
import 'package:backend/models/todo.dart';
import 'package:flutter/material.dart';

class TodoPage extends StatefulWidget {
  final TodoController controller;

  const TodoPage({Key key, this.controller}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Todo> todos;
  bool isLoading = false;

  void _getTodos() async {
    var newTodos = await widget.controller.fetchTodos();
    setState(() {
      todos = newTodos;
    });
  }

  void updateTodo(Todo todoItem, bool isCompleted) async {
    var todo = await widget.controller.updateTodo(todoItem, isCompleted);
    setState(() {});
  }

  void initState() {
    super.initState();
    widget.controller.onSync.listen((bool syncState) => setState(() {
          isLoading = syncState;
        }));
  }

  Widget get body => isLoading
      ? CircularProgressIndicator()
      : ListView.builder(
          itemCount: todos != null ? todos.length : 1,
          itemBuilder: (ctx, idx) {
            if (todos != null) {
              return CheckboxListTile(
                onChanged:(bool val) => updateTodo(todos[idx], val),
                value: todos[idx].completed,
                title: Text(todos[idx].title),
              );
            } else {
              return Text("Tap button to fetch todos");
            }
          });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Http Todos"),
      ),
      body: Center(child: body),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _getTodos(),
        child: Icon(Icons.add),
      ),
    );
  }
}
