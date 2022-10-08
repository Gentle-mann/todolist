import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todolist/services/notifications_service.dart';

import '../classes/database.dart';
import 'add_edit_todo.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Database _database;
  late bool isCompleted = false;
  final NotificationService notificationService = NotificationService();

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

  Future<void> _updateAndSaveTodos(Todo todo, int index) async {
    setState(() {
      _database.todo[index] = todo;
    });
    DatabaseFileRoutines().writeTodos(databaseToJson(_database));
  }

  Future<void> _deleteAndSaveTodos(int index) async {
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
          _updateAndSaveTodos(todoEdit.todo, index);
        }
        if (todoEdit.todo.shouldNotify) {
          await _sendNotification(todoEdit);
        }
        break;
      case 'Cancel':
        break;
      default:
        break;
    }
  }

  Future<void> _sendNotification(TodoEdit todoEdit) async {
    final dueDate = DateTime.parse(todoEdit.todo.dueDate);
    final dueTime = DateTime.parse(todoEdit.todo.dueTime);
    final scheduledDate = tz.TZDateTime.from(
      DateTime(dueDate.year, dueDate.month, dueDate.day, dueTime.hour,
              dueDate.minute)
          .subtract(
        const Duration(hours: 1),
      ),
      tz.local,
    );
    await notificationService.showScheduledNotifications(
      id: int.parse(todoEdit.todo.id),
      title: 'Task Almost Due',
      body:
          'Your task, ${todoEdit.todo.title}, is due at ${DateFormat.Hm().format(dueTime)}!',
      scheduledDate: scheduledDate,
    );
  }

  @override
  void initState() {
    super.initState();
    notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Your ToDos', style: TextStyle(color: Colors.orange)),
        elevation: 0.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(16.0),
          child: Container(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange,
                Colors.orange.shade50,
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        initialData: const [],
        future: _loadTodos(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data.isEmpty) {
            return const Center(
              child: Text(
                'No Todos',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                ),
              ),
            );
          } else {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                final leadingDay = DateFormat.E()
                    .format(DateTime.parse(snapshot.data[index].dueDate));
                final leadingDate = DateFormat.d()
                    .format(DateTime.parse(snapshot.data[index].dueDate));
                final leadingTime = DateFormat.jm()
                    .format(DateTime.parse(snapshot.data[index].dueTime));
                bool newIsCompleted = snapshot.data[index].isCompleted;
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Slidable(
                      startActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              _deleteAndSaveTodos(index);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              addOrEditTodo(
                                add: false,
                                todo: snapshot.data[index],
                                index: index,
                              );
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          )
                        ],
                      ),
                      child: InkWell(
                        onDoubleTap: () {
                          addOrEditTodo(
                            add: false,
                            todo: snapshot.data[index],
                            index: index,
                          );
                        },
                        child: CheckboxListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          dense: false,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          selectedTileColor: Colors.blue.shade200,
                          selected: snapshot.data[index].isCompleted,
                          secondary: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data[index].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                            ],
                          ),
                          subtitle: Text(
                            snapshot.data[index].task,
                            style: const TextStyle(height: 2.0),
                          ),
                          value: newIsCompleted,
                          onChanged: (newValue) async {
                            setState(() {
                              newIsCompleted = newValue!;
                              Todo todo = Todo(
                                isCompleted: newIsCompleted,
                                title: snapshot.data[index].title,
                                dueDate: snapshot.data[index].dueDate,
                                dueTime: snapshot.data[index].dueTime,
                                id: snapshot.data[index].id,
                                task: snapshot.data[index].task,
                                shouldNotify: snapshot.data[index].shouldNotify,
                              );
                              _updateAndSaveTodos(todo, index);
                            });
                            if (newIsCompleted) {
                              await _showDeleteWhenCheckedDialog(index);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final Todo todo = Todo(
            title: '',
            dueDate: '',
            dueTime: '',
            id: '',
            task: '',
            isCompleted: false,
            shouldNotify: false,
          );
          addOrEditTodo(add: true, todo: todo, index: -1);
        },
        tooltip: 'Add to-do Item',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        child: Container(
          height: 40.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.orange,
                Colors.orange.shade50,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteWhenCheckedDialog(index) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          title: const Text('Task Marked Complete!'),
          content: const Text('Would you like to delete task?'),
          actions: [
            TextButton(
              onPressed: () {
                _deleteAndSaveTodos(index);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Keep',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

}
