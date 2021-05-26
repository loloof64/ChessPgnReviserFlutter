// @dart=2.9
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart'
    as board;
import 'package:chess/chess.dart' as board_logic;

class GameSelector extends StatefulWidget {
  final List<dynamic> games;
  var gameIndex = 0;

  GameSelector(this.games);

  String currentFen() {
    //////////////////
    print(games[gameIndex]);
    //////////////////
    return (games[gameIndex]["tags"] ?? {})["FEN"] ?? board_logic.Chess().fen;
  }

  bool whiteTurn() {
    return currentFen().split(' ')[1] == 'w';
  }

  @override
  _GameSelectorState createState() => _GameSelectorState();
}

class _GameSelectorState extends State<GameSelector> {
  gotoFirst() {
    setState(() {
      widget.gameIndex = 0;
    });
  }

  gotoPrevious() {
    setState(() {
      if (widget.gameIndex > 0) widget.gameIndex -= 1;
    });
  }

  gotoNext() {
    setState(() {
      if (widget.gameIndex < widget.games.length - 1) widget.gameIndex += 1;
    });
  }

  gotoLast() {
    setState(() {
      widget.gameIndex = widget.games.length - 1;
    });
  }

  cancel(BuildContext context) {
    Navigator.pop(context);
  }

  validate(BuildContext context) {
    Navigator.pop(context, widget.gameIndex);
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    final size = min(viewport.height * 0.6, viewport.width);
    final fen = widget.currentFen();
    final navigationButtonsSize = size * 0.05;
    final validationButtonsFontSize = size * 0.08;
    final validationButtonsPadding = size * 0.016;
    return Scaffold(
        appBar: AppBar(title: Text('Game selector')),
        body: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton.icon(
                    label: Text(''),
                    icon: Image(
                      image: AssetImage('images/first_item.png'),
                      width: navigationButtonsSize,
                      height: navigationButtonsSize,
                    ),
                    onPressed: gotoFirst,
                  ),
                  TextButton.icon(
                    label: Text(''),
                    icon: Image(
                      image: AssetImage('images/previous_item.png'),
                      width: navigationButtonsSize,
                      height: navigationButtonsSize,
                    ),
                    onPressed: gotoPrevious,
                  ),
                  TextButton.icon(
                    label: Text(''),
                    icon: Image(
                      image: AssetImage('images/next_item.png'),
                      width: navigationButtonsSize,
                      height: navigationButtonsSize,
                    ),
                    onPressed: gotoNext,
                  ),
                  TextButton.icon(
                    label: Text(''),
                    icon: Image(
                      image: AssetImage('images/last_item.png'),
                      width: navigationButtonsSize,
                      height: navigationButtonsSize,
                    ),
                    onPressed: gotoLast,
                  )
                ],
              ),
              board.Chessboard(
                size: size,
                fen: fen,
                orientation:
                    widget.whiteTurn() ? board.Color.WHITE : board.Color.BLACK,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: validationButtonsPadding),
                    child: TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: validationButtonsFontSize),
                      ),
                      style: TextButton.styleFrom(primary: Colors.red),
                      onPressed: () => cancel(context),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: validationButtonsPadding),
                    child: TextButton(
                      child: Text('Ok',
                          style:
                              TextStyle(fontSize: validationButtonsFontSize)),
                      style: TextButton.styleFrom(primary: Colors.blue),
                      onPressed: () => validate(context),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
