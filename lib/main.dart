// @dart=2.9
import 'package:flutter/material.dart';
import 'pages/game_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Pgn Reviser',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: GamePage(),
    );
  }
}
