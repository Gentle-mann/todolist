import 'package:flutter/material.dart';
import 'package:todolist/pages/home.dart';

void main()  {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        bottomAppBarColor: Colors.orangeAccent,
      ),
      home: const Home(),
    );
  }
}