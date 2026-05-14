import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense Tracker"), centerTitle: true),
      body: Center(
        child: Text(
          "Welcome to Expense Tracker",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Add button clicked");
        },

        child: Icon(Icons.add),
      ),
    );
  }
}
