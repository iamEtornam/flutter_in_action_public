import 'dart:convert';
import 'package:http/http.dart';

import 'package:backend/models/todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Services {
  Future<List<Todo>> getTodos();
  Future<Todo> updateTodo(Todo todo);
  Future addTodo();
}

class HttpServices implements Services {
  Client client = new Client();

  Future<List<Todo>> getTodos() async {
    final response = await client.get('https://jsonplaceholder.typicode.com/todos?userId=1');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      var all =  AllTodos.fromJson(json.decode(response.body));
      return all.todos;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load todos ');
    }
  }


  @override
  Future addTodo() {
    // TODO: implement addTodo
    return null;
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    // post todo
    return todo;
  }
}

class FirebaseServices implements Services {
  @override
  Future addTodo() {
    return null;
  }

  @override
  Future<List<Todo>> getTodos() async {
    QuerySnapshot snapshot = await Firestore.instance.collection("todos").getDocuments();
    AllTodos todos = AllTodos.fromSnapshot(snapshot);
    return todos.todos;
  }

  @override
  Future<Todo> updateTodo(Todo todo) {
    // TODO: implement updateTodo
    return null;
  }

}
