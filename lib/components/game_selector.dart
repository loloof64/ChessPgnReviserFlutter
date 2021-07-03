import 'dart:math';
import 'package:chess_pgn_reviser/components/app_bar_actions.dart';
import 'package:chess_pgn_reviser/models/dark_mode_manager.dart';

import '../../constants.dart';
import 'package:flutter/material.dart';
import "package:chess/chess.dart" as board_logic;
import 'chessboard/chessboard.dart' as board;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/dark_mode_manager.dart';

class GameSelectorResult {
  final int gameIndex;
  final PlayerMode whiteMode;
  final PlayerMode blackMode;

  GameSelectorResult({
    required this.gameIndex,
    required this.whiteMode,
    required this.blackMode,
  });
}

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
  PlayerMode _whiteMode = PlayerMode.GuessMove;
  PlayerMode _blackMode = PlayerMode.GuessMove;

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
    Navigator.pop(
        context,
        GameSelectorResult(
            gameIndex: _gameIndex,
            whiteMode: _whiteMode,
            blackMode: _blackMode));
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
    if (goalString == "1-0")
      return AppLocalizations.of(context)?.gameResultWhiteWin ?? errorString;
    if (goalString == "0-1")
      return AppLocalizations.of(context)?.gameResultBlackWin ?? errorString;
    if (goalString.startsWith("1/2"))
      return AppLocalizations.of(context)?.gameResultDraw ?? errorString;
    return goalString;
  }

  bool isBlackTurn() {
    final fen = currentFen();
    final turnString = fen.split(' ')[1];
    return turnString == 'b';
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
        appBar: AppBar(
          title: Text(
              AppLocalizations.of(context)?.gameSelectorTitle ?? errorString),
          actions: [
            AppBarActions(),
          ],
        ),
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
              Container(
                padding: EdgeInsets.symmetric(vertical: 9.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    board.ChessBoard(
                      size: size,
                      fen: fen,
                      blackAtBottom: isBlackTurn(),
                    ),
                    ModeSettingZone(
                      whiteMode: _whiteMode,
                      blackMode: _blackMode,
                      guessMoveString: AppLocalizations.of(context)
                              ?.gameModePlayerGuessMove ??
                          errorString,
                      randomMovesString: AppLocalizations.of(context)
                              ?.gameModeComputerPlaysRandomly ??
                          errorString,
                      userChoiceString: AppLocalizations.of(context)
                              ?.gameModeUserChooseMove ??
                          errorString,
                      updateWhiteMode: (PlayerMode newValue) {
                        setState(() {
                          _whiteMode = newValue;
                        });
                      },
                      updateBlackMode: (PlayerMode newValue) {
                        setState(() {
                          _blackMode = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
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

class ModeSettingZone extends StatelessWidget {
  final PlayerMode whiteMode;
  final PlayerMode blackMode;
  final String guessMoveString;
  final String userChoiceString;
  final String randomMovesString;

  final void Function(PlayerMode mode) updateWhiteMode;
  final void Function(PlayerMode mode) updateBlackMode;

  ModeSettingZone({
    required this.whiteMode,
    required this.blackMode,
    required this.updateWhiteMode,
    required this.updateBlackMode,
    required this.guessMoveString,
    required this.userChoiceString,
    required this.randomMovesString,
  });

  String textForMode(PlayerMode mode) {
    switch (mode) {
      case PlayerMode.GuessMove:
        return guessMoveString;
      case PlayerMode.ReadMoveByUserChoice:
        return userChoiceString;
      case PlayerMode.ReadMoveRandomly:
        return randomMovesString;
      default:
        throw 'Unrecognized mode $mode !';
    }
  }

  IconData iconForMode(PlayerMode mode) {
    switch (mode) {
      case PlayerMode.GuessMove:
        return FontAwesomeIcons.questionCircle;
      case PlayerMode.ReadMoveByUserChoice:
        return FontAwesomeIcons.codeBranch;
      case PlayerMode.ReadMoveRandomly:
        return FontAwesomeIcons.dice;
      default:
        throw 'Unrecognized mode $mode !';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropDownItems = PlayerMode.values
        .map((currentValue) => DropdownMenuItem(
              child: Row(
                children: [
                  FaIcon(
                    iconForMode(currentValue),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    textForMode(currentValue),
                  ),
                ],
              ),
              value: currentValue,
            ))
        .toList();

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(AppLocalizations.of(context)?.whiteMode ?? errorString),
            SizedBox(
              width: 20.0,
            ),
            DropdownButton<PlayerMode>(
              items: dropDownItems,
              value: whiteMode,
              onChanged: (PlayerMode? newValue) {
                updateWhiteMode(newValue ?? PlayerMode.GuessMove);
              },
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(AppLocalizations.of(context)?.blackMode ?? errorString),
            SizedBox(
              width: 20.0,
            ),
            DropdownButton<PlayerMode>(
              items: dropDownItems,
              value: blackMode,
              onChanged: (PlayerMode? newValue) {
                updateBlackMode(newValue ?? PlayerMode.GuessMove);
              },
            ),
          ],
        )
      ],
    );
  }
}

class NavigationProgress extends StatelessWidget {
  final double fontSize;
  final int gamesCount;
  final double indexFieldWidth;
  final TextEditingController? indexFieldController;
  final void Function(String)? onIndexFieldSubmitted;

  NavigationProgress({
    required this.fontSize,
    required this.gamesCount,
    this.indexFieldWidth = 50.0,
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
  final void Function()? onValidate;
  final void Function()? onCancel;

  ValidationZone(
      {this.buttonsFontSize = 18.0,
      this.buttonsPadding = 10.0,
      this.onValidate,
      this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ValidationButton(
          label: AppLocalizations.of(context)?.cancelButton ?? errorString,
          fontSize: buttonsFontSize,
          padding: buttonsPadding,
          onPressed: onCancel ?? () {},
          textColor: Colors.red,
        ),
        ValidationButton(
          label: AppLocalizations.of(context)?.okButton ?? errorString,
          fontSize: buttonsFontSize,
          padding: buttonsPadding,
          onPressed: onValidate ?? () {},
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
  final void Function()? onPressed;
  final Color textColor;

  ValidationButton(
      {required this.label,
      this.fontSize = 18.0,
      this.padding = 10.0,
      this.textColor = Colors.white,
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
    required this.buttonsSize,
    required this.onGotoFirst,
    required this.onGotoPrevious,
    required this.onGotoNext,
    required this.onGotoLast,
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
  final void Function()? onPressed;

  NavigationButton(
      {required this.size, required this.imageReference, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeManager>(context).isActive;

    return Container(
      child: TextButton.icon(
        label: Text(''),
        icon: Image(
          image: AssetImage(imageReference),
          width: size,
          height: size,
        ),
        onPressed: onPressed,
      ),
      color: isDarkMode ? Colors.white38 : Colors.transparent,
    );
  }
}
