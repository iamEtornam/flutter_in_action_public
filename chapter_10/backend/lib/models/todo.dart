import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

@JsonSerializable()
class Todo {
  final int  userId;
  final int id;
  final String title;
  bool completed;

  Todo(this.userId, this.id, this.title, this.completed);

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoToJson(this);
}

@JsonSerializable()
class AllTodos {
  final List<Todo> todos;

  AllTodos(this.todos);

  factory AllTodos.fromJson(List<dynamic> json) {
      List<Todo> todos = new List<Todo>();
      todos = json.map((i) => Todo.fromJson(i)).toList();
      return new AllTodos(todos);
  }

  factory AllTodos.fromSnapshot(QuerySnapshot s) {
    List<Todo> todos = s.documents.map((DocumentSnapshot ds) {
      return new Todo.fromJson(ds.data);
    }).toList();
    return AllTodos(todos);
  }

  Map<String, dynamic> toJson() => _$AllTodosToJson(this);
}