import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("First App")),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.grey),
              child: Text("One"),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.red),
              child: Text("Two"),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Three"),
            ),
          ],
        ),
      ),
    ),
  );
}
