// @dart=2.9
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as board_logic;
import 'chessboard/chessboard.dart' as board;

class GameSelector extends StatefulWidget {
  final List<dynamic> games;
  GameSelector(
    this.games,
  );

  @override
  _GameSelectorState createState() => _GameSelectorState();
}

class _GameSelectorState extends State<GameSelector> {
  int _gameIndex = 0;

  gotoFirst() {
    setState(() {
      _gameIndex = 0;
    });
  }

  gotoPrevious() {
    setState(() {
      if (_gameIndex > 0) _gameIndex -= 1;
    });
  }

  gotoNext() {
    setState(() {
      if (_gameIndex < widget.games.length - 1) _gameIndex += 1;
    });
  }

  gotoLast() {
    setState(() {
      _gameIndex = widget.games.length - 1;
    });
  }

  cancel(BuildContext context) {
    Navigator.pop(context);
  }

  validate(BuildContext context) {
    Navigator.pop(context, _gameIndex);
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
        _gameIndex = gameIndex;
      });
    } catch (ex) {
      resetText();
      return;
    }
  }

  String getGameGoal() {
    final goalString = widget.games[_gameIndex]["tags"]["Goal"] ?? "";
    if (goalString == "1-0") return "White should win";
    if (goalString == "0-1") return "Black should win";
    if (goalString.startsWith("1/2")) return "It should be draw";
    return goalString;
  }

  bool isBlackTurn() {
    return widget.games[_gameIndex]["moves"]["pgn"][0]["turn"] == "b";
  }

  String currentFen() {
    return (widget.games[_gameIndex]["tags"] ?? {})["FEN"] ??
        board_logic.Chess().fen;
  }

  bool whiteTurnInGameSelector() {
    return currentFen().split(' ')[1] == 'w';
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    final size = min(viewport.height * 0.6, viewport.width);
    final fen = currentFen();
    final navigationButtonsSize = size * 0.05;
    final validationButtonsFontSize = size * 0.08;
    final validationButtonsPadding = size * 0.016;
    final navigationFontSize = size * 0.08;

    TextEditingController textController =
        TextEditingController(text: "${_gameIndex + 1}");

    return Scaffold(
        appBar: AppBar(title: Text('Game selector')),
        body: Center(
          child: Column(
            children: [
              NavigationProgress(
                fontSize: navigationFontSize,
                gamesCount: widget.games.length,
                indexFieldController: textController,
                indexFieldWidth: size * 0.16,
                onIndexFieldSubmitted: (value) => tryNavigatingAt(value),
              ),
              NavigationZone(
                buttonsSize: navigationButtonsSize,
                onGotoFirst: gotoFirst,
                onGotoNext: gotoNext,
                onGotoLast: gotoLast,
                onGotoPrevious: gotoPrevious,
              ),
              board.ChessBoard(
                  size: size, fen: fen, blackAtBottom: isBlackTurn()),
              Padding(
                child: Text(
                  getGameGoal(),
                  style: TextStyle(fontSize: navigationFontSize),
                ),
                padding:
                    EdgeInsets.symmetric(vertical: validationButtonsPadding),
              ),
              ValidationZone(
                buttonsFontSize: validationButtonsFontSize,
                buttonsPadding: validationButtonsPadding,
                onCancel: () => cancel(context),
                onValidate: () => validate(context),
              ),
            ],
          ),
        ));
  }
}

class NavigationProgress extends StatelessWidget {
  final double indexFieldWidth;
  final TextEditingController indexFieldController;
  final double fontSize;
  final int gamesCount;
  final void Function(String) onIndexFieldSubmitted;

  NavigationProgress({
    @required this.fontSize,
    @required this.gamesCount,
    this.indexFieldWidth,
    this.indexFieldController,
    this.onIndexFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: indexFieldWidth,
          child: TextField(
            controller: indexFieldController,
            onSubmitted: onIndexFieldSubmitted,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: fontSize),
          ),
        ),
        Text("/", style: TextStyle(fontSize: fontSize)),
        Text("$gamesCount", style: TextStyle(fontSize: fontSize))
      ],
    );
  }
}

class ValidationZone extends StatelessWidget {
  final double buttonsFontSize;
  final double buttonsPadding;
  final void Function() onValidate;
  final void Function() onCancel;

  ValidationZone(
      {this.buttonsFontSize,
      this.buttonsPadding,
      this.onValidate,
      this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ValidationButton(
          label: 'Cancel',
          fontSize: buttonsFontSize,
          padding: buttonsPadding,
          onPressed: onCancel,
          textColor: Colors.red,
        ),
        ValidationButton(
          label: 'Ok',
          fontSize: buttonsFontSize,
          padding: buttonsPadding,
          onPressed: onValidate,
          textColor: Colors.blue,
        ),
      ],
    );
  }
}

class ValidationButton extends StatelessWidget {
  final String label;
  final double padding;
  final double fontSize;
  final void Function() onPressed;
  final Color textColor;

  ValidationButton(
      {@required this.label,
      this.fontSize,
      this.padding,
      this.textColor,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: TextButton(
        child: Text(
          label,
          style: TextStyle(fontSize: fontSize),
        ),
        style: TextButton.styleFrom(primary: textColor),
        onPressed: onPressed,
      ),
    );
  }
}

class NavigationZone extends StatelessWidget {
  final double buttonsSize;
  final void Function() onGotoFirst;
  final void Function() onGotoPrevious;
  final void Function() onGotoNext;
  final void Function() onGotoLast;

  NavigationZone({
    @required this.buttonsSize,
    this.onGotoFirst,
    this.onGotoPrevious,
    this.onGotoNext,
    this.onGotoLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        NavigationButton(
            size: buttonsSize,
            imageReference: 'images/first_item.png',
            onPressed: onGotoFirst),
        NavigationButton(
            size: buttonsSize,
            imageReference: 'images/previous_item.png',
            onPressed: onGotoPrevious),
        NavigationButton(
            size: buttonsSize,
            imageReference: 'images/next_item.png',
            onPressed: onGotoNext),
        NavigationButton(
          size: buttonsSize,
          imageReference: 'images/last_item.png',
          onPressed: onGotoLast,
        ),
      ],
    );
  }
}

class NavigationButton extends StatelessWidget {
  final double size;
  final String imageReference;
  final void Function() onPressed;

  NavigationButton({@required this.size, this.imageReference, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      label: Text(''),
      icon: Image(
        image: AssetImage(imageReference),
        width: size,
        height: size,
      ),
      onPressed: onPressed,
    );
  }
}
