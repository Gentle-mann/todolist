import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../classes/database.dart';

class AddOrEditTodo extends StatefulWidget {
  const AddOrEditTodo(
      {Key? key,
      required this.add,
      required this.todoEdit,
      required this.index})
      : super(key: key);
  final bool add;
  final TodoEdit todoEdit;
  final int index;

  @override
  State<AddOrEditTodo> createState() => _AddOrEditTodoState();
}

class _AddOrEditTodoState extends State<AddOrEditTodo> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _taskFocus = FocusNode();
  late DateTime _selectedDate;
  late TodoEdit _todoEdit;

  Future<DateTime> _showDatePicker(DateTime date) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      date = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _selectedDate.hour,
        _selectedDate.minute,
      );
    }
    return date;
  }

  Future<DateTime> _showTimePicker(DateTime time) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: _selectedDate.hour, minute: _selectedDate.minute),
    );
    if (pickedTime != null) {
      time = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    }
    return time;
  }

  @override
  void initState() {
    super.initState();
    _todoEdit = TodoEdit(
      action: 'Cancel',
      todo: widget.todoEdit.todo,
    );
    _todoEdit.todo = widget.todoEdit.todo;
    if (widget.add) {
      _selectedDate = DateTime.now();
      _taskController.text = '';
      _titleController.text = '';
    } else {
      _taskController.text = _todoEdit.todo.task;
      _titleController.text = _todoEdit.todo.title;
      _selectedDate = DateTime.parse(_todoEdit.todo.dueDate);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _taskController.dispose();
    _titleFocus.dispose();
    _taskFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.add ? 'Add' : 'Edit';
    return Scaffold(
      appBar: AppBar(
        title: Text('$title Todo'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              _todoEdit.action = 'Cancel';
              Navigator.pop(context, _todoEdit);
            },
            icon: const Icon(
              Icons.cancel_outlined,
              size: 28.0,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Due date',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.deepOrangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      buildDateButton(),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Due time',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      buildTimeButton(),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  buildTitleField(),
                  const SizedBox(height: 12.0),
                  buildTaskField(),
                  const SizedBox(height: 24.0),
                  buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SizedBox buildSaveButton() {
    return SizedBox(
      height: 48.0,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final bool isValid = formKey.currentState!.validate();
          if (isValid) {
            final String id = widget.add
                ? Random().nextInt(99999999).toString()
                : _todoEdit.todo.id;
            _todoEdit.action = 'Save';
            _todoEdit.todo = Todo(
              title: _titleController.text,
              dueDate: _selectedDate.toString(),
              dueTime: _selectedDate.toString(),
              id: id,
              task: _taskController.text,
              isCompleted: _todoEdit.todo.isCompleted,
            );
            Navigator.pop(context, _todoEdit);
          }
        },
        child: const Text(
          'Save',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }

  TextFormField buildTaskField() {
    return TextFormField(
      focusNode: _taskFocus,
      controller: _taskController,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.newline,
      decoration: const InputDecoration(
        icon: Icon(Icons.task),
        border: OutlineInputBorder(),
        label: Text(
          'Enter Task',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      maxLines: null,
    );
  }

//add validator
  TextFormField buildTitleField() {
    return TextFormField(
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      focusNode: _titleFocus,
      controller: _titleController,
      style: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
        color: Colors.orange,
      ),
      decoration: const InputDecoration(
        icon: Icon(Icons.title),
        border: OutlineInputBorder(),
        label: Text(
          'Enter Title',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Title cannot be empty';
        } else {
          return null;
        }
      },
    );
  }

  ElevatedButton buildTimeButton() {
    return ElevatedButton(
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.all(const Size.fromHeight(64.0)),
      ),
      onPressed: () async {
        DateTime chosenTime = await _showTimePicker(_selectedDate);
        setState(() {
          _selectedDate = chosenTime;
        });
      },
      child: Row(
        children: [
          Text(
            DateFormat.Hm().format(_selectedDate),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  ElevatedButton buildDateButton() {
    return ElevatedButton(
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.all(const Size.fromHeight(64.0)),
      ),
      onPressed: () async {
        DateTime chosenDate = await _showDatePicker(_selectedDate);
        setState(() {
          _selectedDate = chosenDate;
        });
      },
      child: Row(
        children: [
          Text(DateFormat.yMMMEd().format(_selectedDate)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
