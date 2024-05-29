import 'package:flutter/material.dart';

import 'screens/ingredients_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ingredients App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IngredientsPage(),
    );
  }
}