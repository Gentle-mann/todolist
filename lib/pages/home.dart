import 'package:flutter/material.dart';
import '../classes/database.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Database _database;
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _todoEditController = TextEditingController();
  final FocusNode _todoFocus = FocusNode();
  final FocusNode _todoEditFocus = FocusNode();

  Future<List<Todo>> _loadTodos() async {
    await DatabaseFileRoutines().readTodos().then((value) {
      _database = databaseFromJson(value);
    });
    return _database.todo;
  }

  Future _addTodoDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add To-do'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4,
          contentPadding: const EdgeInsets.all(16.0),
          content: TextField(
            controller: _todoController,
            decoration: const InputDecoration(
                icon: Icon(Icons.note_alt),
                labelText: 'Add your to-do item...'),
            focusNode: _todoFocus,
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_todoController.text.isNotEmpty) {
                  final Todo todoItem =
                      Todo(todo: _todoController.text);
                  setState(() {
                    _database.todo.add(todoItem);
                  });
                  DatabaseFileRoutines().writeTodos(databaseToJson(_database));
                  Navigator.pop(context);
                  _todoController.clear();
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _todoController.dispose();
    _todoEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your To-dos'),
      ),
      body: FutureBuilder(
        initialData: const [],
        future: _loadTodos(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return !snapshot.hasData
              ? const CircularProgressIndicator()
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      onDismissed: (direction) {
                        setState(() {
                          _database.todo.removeAt(index);
                        });
                        DatabaseFileRoutines()
                            .writeTodos(databaseToJson(_database));
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
                      key: Key(snapshot.data[index].todo),
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(6.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          title: Text(snapshot.data[index].todo),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              setState(() {
                                _database.todo.removeAt(index);
                              });
                              DatabaseFileRoutines()
                                  .writeTodos(databaseToJson(_database));
                            },
                          ),
                          onTap: () {
                            showDialog(context: context, builder: (context) {
                              Todo todo = Todo(todo: snapshot.data[index].todo);
                              TodoEdit todoEdit = TodoEdit(todo);
                              _todoEditController.text = todoEdit.todo.todo;
                              return AlertDialog(
                                title: const Text('Edit To Do'),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                contentPadding: const EdgeInsets.all(10.0),
                                content: TextField(
                                  controller: _todoEditController,
                                  autofocus: true,
                                  focusNode: _todoEditFocus,
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.note_alt),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Todo todo = Todo(todo: _todoEditController.text);
                                      todoEdit = TodoEdit(todo);
                                      setState(() {
                                        _database.todo[index] = todoEdit.todo;
                                      });
                                      DatabaseFileRoutines().writeTodos(databaseToJson(_database));
                                    },
                                    child: const Text('Save'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            });
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
        onPressed: () async {
          await _addTodoDialog();
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
}
