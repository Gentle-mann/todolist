import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class DatabaseFileRoutines {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/todolistl');
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
  final String todo;

  Todo({required this.todo});

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    todo: json["todo"],
  );

  Map<String, dynamic> toJson() => {
    "todo": todo,
  };
}

class TodoEdit {
  final Todo todo;

  TodoEdit(this.todo);

}
