import 'package:flutter/material.dart';
import 'location_list.dart';

// make main() call this widget
class App extends StatelessWidget {
  // constructor
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LocationList());
  }
}
