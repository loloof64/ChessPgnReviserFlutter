// @dart=2.9
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as board_logic;
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart' as board;

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Chess Pgn Reviser'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  board_logic.Chess boardState = board_logic.Chess();

  makeMove(board.ShortMove move, String promotion) {
    final moveDone = boardState.move({'from': move.from, 'to': move.to, 'promotion': 'q'});
    if (moveDone) {
      // We need to notify that state has been updated.
      setState(() {
        
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    final size = min(viewport.height * 0.8, viewport.width);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            board.Chessboard(fen: boardState.fen, size: size, onMove: (move) {
              makeMove(move, 'q');
            })
                        ],
                      ),
                    ),
                  );
                }
}
