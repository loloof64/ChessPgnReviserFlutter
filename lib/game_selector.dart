// @dart=2.9
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as board_logic;
import 'package:chess_pgn_reviser/chessboard/chessboard.dart' as board;

class GameSelector extends StatefulWidget {
  final List<dynamic> games;
  var gameIndex = 0;

  GameSelector(this.games);

  String currentFen() {
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

  resetText() {
    setState(() {});
  }

  tryNavigatingAt(String value) {
    try {
      final gameIndex = int.parse(value) - 1;
      if (gameIndex < 0 || gameIndex > widget.games.length - 1) {
        resetText();
        return;
      }
      setState(() {
        widget.gameIndex = gameIndex;
      });
    } catch (ex) {
      resetText();
      return;
    }
  }

  String getGameGoal() {
    final goalString = widget.games[widget.gameIndex]["tags"]["Goal"] ?? "";
    if (goalString == "1-0") return "White should win";
    if (goalString == "0-1") return "Black should win";
    if (goalString.startsWith("1/2")) return "It should be draw";
    return goalString;
  }

  bool isBlackTurn() {
    final currentGame = widget.games[widget.gameIndex];
    return currentGame["moves"]["pgn"][0]["turn"] == "b";
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    final size = min(viewport.height * 0.6, viewport.width);
    final fen = widget.currentFen();
    final navigationButtonsSize = size * 0.05;
    final validationButtonsFontSize = size * 0.08;
    final validationButtonsPadding = size * 0.016;
    final navigationFontSize = size * 0.08;

    TextEditingController textController =
        TextEditingController(text: "${widget.gameIndex + 1}");

    return Scaffold(
        appBar: AppBar(title: Text('Game selector')),
        body: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: size * 0.16,
                    child: TextField(
                      controller: textController,
                      onSubmitted: (value) => tryNavigatingAt(value),
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: navigationFontSize),
                    ),
                  ),
                  Text("/", style: TextStyle(fontSize: navigationFontSize)),
                  Text("${widget.games.length}",
                      style: TextStyle(fontSize: navigationFontSize))
                ],
              ),
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
              board.ChessBoard(
                  size: size, fen: fen, blackAtBottom: !widget.whiteTurn()),
              Padding(
                child: Text(
                  getGameGoal(),
                  style: TextStyle(fontSize: navigationFontSize),
                ),
                padding:
                    EdgeInsets.symmetric(vertical: validationButtonsPadding),
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
