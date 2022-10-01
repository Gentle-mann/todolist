import 'package:flutter/material.dart';
import '../classes/database.dart';
import 'add_edit_todo.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Database _database;

  Future<List<Todo>> _loadTodos() async {
    await DatabaseFileRoutines().readTodos().then((value) {
      _database = databaseFromJson(value);
      _database.todo
          .sort((task1, task2) => task2.dueDate.compareTo(task1.dueDate));
    });
    return _database.todo;
  }

  Future<void> _addAndSaveTodos(Todo todo) async {
    setState(() {
      _database.todo.add(todo);
    });
    DatabaseFileRoutines().writeTodos(databaseToJson(_database));
  }

  Future<void> _updateAndSaveTodos(TodoEdit todoEdit, int index) async {
    setState(() {
      _database.todo[index] = todoEdit.todo;
    });
    DatabaseFileRoutines().writeTodos(databaseToJson(_database));
  }

  Future<void> _deleteAndSaveTodos(index) async {
    setState(() {
      _database.todo.removeAt(index);
    });
    DatabaseFileRoutines().writeTodos(databaseToJson(_database));
  }

  Future<void> addOrEditTodo(
      {required bool add, required Todo todo, required int index}) async {
    TodoEdit todoEdit = TodoEdit(todo: todo, action: '');
    todoEdit = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddOrEditTodo(add: add, todoEdit: todoEdit, index: index),
      ),
    );
    switch (todoEdit.action) {
      case 'Save':
        if (add) {
          _addAndSaveTodos(todoEdit.todo);
        } else {
          _updateAndSaveTodos(todoEdit, index);
        }
        break;
      case 'Cancel':
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your ToDos'),
      ),
      body: FutureBuilder(
        initialData: const [],
        future: _loadTodos(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return !snapshot.hasData
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final leadingDay = DateFormat.E()
                        .format(DateTime.parse(snapshot.data[index].dueDate));
                    final leadingDate = DateFormat.d()
                        .format(DateTime.parse(snapshot.data[index].dueDate));
                    final leadingTime = DateFormat.Hm()
                        .format(DateTime.parse(snapshot.data[index].dueTime));
                    return Dismissible(
                      onDismissed: (direction) {
                        _deleteAndSaveTodos(index);
                      },
                      background: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      //Replace these with #slidable
                      secondaryBackground: Container(
                        padding: const EdgeInsets.all(10.0),
                        color: Colors.green,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      key: Key(snapshot.data[index].id),
                      confirmDismiss: _showConfirmDismissDialog,
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(6.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: Column(
                            children: [
                              Text(
                                '$leadingDay, $leadingDate',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                leadingTime,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            snapshot.data[index].title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          subtitle: Text(snapshot.data[index].task),
                          onTap: () async {
                            await addOrEditTodo(
                                add: false,
                                todo: snapshot.data[index],
                                index: index);
                          },
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final Todo todo = Todo(
            title: '',
            dueDate: '',
            dueTime: '',
            id: '',
            task: '',
          );
          addOrEditTodo(add: true, todo: todo, index: -1);
        },
        tooltip: 'Add to-do Item',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: EdgeInsets.all(24.0),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDismissDialog(DismissDirection direction) async {
    bool? action;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          title: const Text('Delete Todo'),
          content: const Text('Are you sure you would like to delete?'),
          actions: [
            TextButton(
              onPressed: () {
                action = true;
                //_deleteAndSaveTodos(index);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                action = false;
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
    return action;
  }
}
