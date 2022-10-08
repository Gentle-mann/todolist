import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DatabaseFileRoutines {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/todolist11');
  }

  Future<File> writeTodos(String jsonTodo) async {
    final file = await _localFile;
    return file.writeAsString(jsonTodo);
  }

  Future<String> readTodos() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        await writeTodos('{"todos": []}');
      }
      final String contents = await file.readAsString();
      return contents;
    } on Exception {
      return "";
    }
  }
}

Database databaseFromJson(String str) {
  final dataFromJson = json.decode(str);
  return Database.fromJson(dataFromJson);
}

String databaseToJson(Database data) {
  final dataToJson = data.toJson();
  return json.encode(dataToJson);
}

class Database {
  final List<Todo> todo;

  Database({required this.todo});

  factory Database.fromJson(Map<String, dynamic> json) => Database(
        todo: List<Todo>.from(
          json["todos"].map(
            (x) => Todo.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "todos": List<dynamic>.from(
          todo.map(
            (x) => x.toJson(),
          ),
        ),
      };
}

class Todo {
  final String task;
  final String title;
  final String dueDate;
  final String dueTime;
  final String id;
  final bool isCompleted;
  final bool shouldNotify;

  Todo({
    required this.shouldNotify,
    required this.isCompleted,
    required this.title,
    required this.dueDate,
    required this.dueTime,
    required this.id,
    required this.task,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        task: json["task"],
        title: json["title"],
        dueDate: json["dueDate"],
        dueTime: json["dueTime"],
        id: json["id"],
        isCompleted: json["isCompleted"],
        shouldNotify: json["shouldNotify"],
      );

  Map<String, dynamic> toJson() => {
        "task": task,
        "title": title,
        "dueDate": dueDate,
        "dueTime": dueTime,
        "id": id,
        "isCompleted": isCompleted,
        "shouldNotify": shouldNotify,
      };
}

class TodoEdit {
  Todo todo;
  String action;

  TodoEdit({required this.todo, required this.action});
}
