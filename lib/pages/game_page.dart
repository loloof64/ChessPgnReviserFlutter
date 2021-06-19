// @dart=2.9
import 'dart:async';
import 'dart:math';

import '../constants.dart';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as board_logic;
import 'package:petitparser/context.dart';
import 'package:toast/toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import '../utils/pgn_parser/pgn_parser.dart';
import '../components/game_selector.dart';
import '../components/chessboard/chessboard.dart' as board;
import '../components/chessboard/chessboard_types.dart';
import '../components/history.dart';
import '../utils/chess_utils.dart' as chess_utils;
import '../components/header_bar.dart';
import '../components/bottom_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/dark_mode_manager.dart';

const EMPTY_BOARD = "8/8/8/8/8/8/8/8 w - - 0 1";

class UnexpectedMoveException implements Exception {
  final String moveFan;
  final List<String> expectedMovesFanList;
  UnexpectedMoveException(this.moveFan, this.expectedMovesFanList);
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  board_logic.Chess _boardState = board_logic.Chess.fromFEN(EMPTY_BOARD);
  bool _pendingPromotion = false;
  Move _pendingPromotionMove;
  bool _boardReversed = false;
  bool _lastMoveVisible = false;
  int _lastMoveStartFile;
  int _lastMoveStartRank;
  int _lastMoveEndFile;
  int _lastMoveEndRank;
  String _goalString = "";
  bool _gameInProgress = false;
  List<HistoryItem> _historyWidgetContent = [];
  var _referenceGame;
  int _moveNumber = -1;
  String _startPosition;
  int _currentNodeIndex;
  var _parentNode;
  int _selectedHistoryItemIndex;
  PlayerMode _whiteMode;
  PlayerMode _blackMode;
  bool _loading = false;
  List<bool> _darkModeButtonsSelection = <bool>[true, false];

  void processMoveFanIntoHistoryWidgetMoves(String moveFan, bool isWhiteTurn) {
    _historyWidgetContent.add(HistoryItem(
        text: moveFan,
        fenAfterMove: _boardState.fen,
        lastMoveStartFile: _lastMoveStartFile,
        lastMoveStartRank: _lastMoveStartRank,
        lastMoveEndFile: _lastMoveEndFile,
        lastMoveEndRank: _lastMoveEndRank));
    if (!isWhiteTurn) {
      setState(() {
        _moveNumber += 1;
      });
      _historyWidgetContent.add(HistoryItem.moveNumber(
          _moveNumber, _boardState.turn == board_logic.Color.BLACK));
    }
  }

  bool shouldChessBoardBetInteractive() {
    if (!_gameInProgress) return false;
    final isWhiteTurn = _boardState.turn == board_logic.Color.WHITE;
    final currentMode = isWhiteTurn ? _whiteMode : _blackMode;

    return currentMode == PlayerMode.GuessMove;
  }

  Future<void> tryToMakeComputerPlayRandomMove() async {
    if (!_gameInProgress) return;

    final isWhiteTurn = _boardState.turn == board_logic.Color.WHITE;
    final currentMode = isWhiteTurn ? _whiteMode : _blackMode;
    if (currentMode != PlayerMode.ReadMoveRandomly) return;

    final movesSanList = getAvailableMovesAsSanAndFilterByLegalMoves();
    final movesList = getMoveListFromSanList(movesSanList);
    board_logic.Move selectedMove;
    int selectedMoveIndex;
    do {
      selectedMoveIndex = Random().nextInt(movesList.length);
      selectedMove = movesList[selectedMoveIndex];
    } while (selectedMove == null);
    final moveSan = movesSanList[selectedMoveIndex];

    final moveFan = chess_utils.moveFanFromMoveSan(
        moveSan, _boardState.turn == board_logic.Color.WHITE);

    return await commitSingleMove(selectedMove, moveSan, moveFan);
  }

  Future<void> letUserChooserNextMoveIfAppropriate() async {
    if (!_gameInProgress) return;

    final isWhiteTurn = _boardState.turn == board_logic.Color.WHITE;
    final currentMode = isWhiteTurn ? _whiteMode : _blackMode;
    if (currentMode != PlayerMode.ReadMoveByUserChoice) return;

    final movesSanList = getAvailableMovesAsSanAndFilterByLegalMoves();
    final movesList = getMoveListFromSanList(movesSanList);

    final isSingleMove = movesList.length == 1;
    if (isSingleMove) {
      final move = movesList[0];
      final moveSan = _boardState.move_to_san(move);
      final moveFan = chess_utils.moveFanFromMoveSan(
          moveSan, _boardState.turn == board_logic.Color.WHITE);
      return await commitSingleMove(move, moveSan, moveFan);
    }

    List<AlertDialogAction<int>> movesActions = [];

    movesSanList.asMap().forEach((index, moveSan) {
      final moveFan = chess_utils.moveFanFromMoveSan(
          moveSan, _boardState.turn == board_logic.Color.WHITE);
      movesActions.add(AlertDialogAction(
          key: index, label: moveFan, isDefaultAction: false));
    });

    final moveIndex = await showConfirmationDialog<int>(
        title: AppLocalizations.of(context).moveChoiceConfirmationTitle,
        context: context,
        message: AppLocalizations.of(context).moveChoiceConfirmationMessage,
        okLabel: AppLocalizations.of(context).okButton,
        cancelLabel: AppLocalizations.of(context).cancelButton,
        barrierDismissible: false,
        actions: movesActions);

    try {
      final selectedMove = movesList[moveIndex];
      final selectedMoveSan = movesSanList[moveIndex];
      final moveFan = chess_utils.moveFanFromMoveSan(
          selectedMoveSan, _boardState.turn == board_logic.Color.WHITE);
      return await commitSingleMove(selectedMove, selectedMoveSan, moveFan);
    } catch (e) {
      // If user has cancelled, we must show him this dialog again.
      return await letUserChooserNextMoveIfAppropriate();
    }
  }

  Future<void> commitSingleMove(
      board_logic.Move move, String moveSan, String moveFan) async {
    final startCell = Cell.fromAlgebraic(move.fromAlgebraic);
    final endCell = Cell.fromAlgebraic(move.toAlgebraic);

    _boardState.move(moveSan);
    setState(() {
      _lastMoveVisible = true;
      _lastMoveStartFile = startCell.file;
      _lastMoveStartRank = startCell.rank;
      _lastMoveEndFile = endCell.file;
      _lastMoveEndRank = endCell.rank;
    });
    processMoveFanIntoHistoryWidgetMoves(
        moveFan, _boardState.turn != board_logic.Color.WHITE);
    updateCurrentNode(moveSan, moveFan);

    await tryToMakeComputerPlayRandomMove();
    return await letUserChooserNextMoveIfAppropriate();
  }

  String _getGameGoal(gamePgn) {
    final goalString = gamePgn["tags"]["Goal"] ?? "";
    if (goalString == "1-0")
      return AppLocalizations.of(context).gameResultWhiteWin;
    if (goalString == "0-1")
      return AppLocalizations.of(context).gameResultBlackWin;
    if (goalString.startsWith("1/2"))
      return AppLocalizations.of(context).gameResultDraw;
    return goalString;
  }

  Future<void> loadPgn(BuildContext context) async {
    final XTypeGroup pgnTypeGroup = XTypeGroup(
      label: 'pgn file',
      extensions: ['pgn'],
      mimeTypes: ['application/vnd.chess-pgn', 'application/x-chess-pgn'],
    );

    final XTypeGroup allTypeGroup = XTypeGroup(
      label: 'all files',
      extensions: ['*'],
      mimeTypes: ['application/octet-stream'],
    );

    final XFile file =
        await openFile(acceptedTypeGroups: [pgnTypeGroup, allTypeGroup]);
    if (file == null) {
      Toast.show(AppLocalizations.of(context).cancelledNewGameRequest, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final content = await file.readAsString();
      final definition = PgnParserDefinition();
      final parser = definition.build();
      final parseResult = parser.parse(content);

      final tempValue = parseResult.value;

      final allGames = tempValue is List && tempValue[0] is Failure<dynamic>
          ? tempValue.last
          : tempValue;

      final gameData = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => GameSelector(allGames)));
      final userCancellation = gameData == null;
      if (userCancellation) {
        setState(() {
          _loading = false;
        });
        Toast.show(
            AppLocalizations.of(context).cancelledNewGameRequest, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
      final game = allGames[gameData.gameIndex];
      final fen = (game["tags"] ?? {})["FEN"] ?? board_logic.Chess().fen;

      final gameLogic = board_logic.Chess.fromFEN(fen);
      chess_utils.checkPiecesCount(gameLogic);
      final moves = gameLogic.generate_moves();
      final noMoreMove = moves.isEmpty;

      if (noMoreMove) {
        throw Exception(AppLocalizations.of(context).noMoveInLoadedGame);
      }

      String startFen;
      final tags = game['tags'];
      if (tags != null) {
        if (tags['FEN'] != null) startFen = tags['FEN'];
      }
      if (startFen == null) startFen = board_logic.Chess.DEFAULT_POSITION;

      setState(() {
        _referenceGame = game;
        _whiteMode = gameData.whiteMode;
        _blackMode = gameData.blackMode;
        _parentNode = game['moves']['pgn'];
        _currentNodeIndex = 0;
        _startPosition = startFen;
        final firstMove = _referenceGame['moves']['pgn'];
        _moveNumber = firstMove.length > 0 ? firstMove[0]['moveNumber'] : 1;
        final blackTurn =
            firstMove.length > 0 ? firstMove[0]['turn'] != 'w' : false;
        _historyWidgetContent.clear();
        _historyWidgetContent
            .add(HistoryItem.moveNumber(_moveNumber, blackTurn));
        _goalString = _getGameGoal(game);
        _boardState = board_logic.Chess.fromFEN(fen);
        _boardReversed = fen.split(" ")[1] == "b";
        _gameInProgress = true;
      });
      clearLastMoveArrow();
      await tryToMakeComputerPlayRandomMove();
      await letUserChooserNextMoveIfAppropriate();
      setState(() {
        _loading = false;
      });
    } catch (ex, stacktrace) {
      setState(() {
        _loading = false;
      });
      Completer().completeError(ex, stacktrace);
      Toast.show(AppLocalizations.of(context).couldNotLoadPgn, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  List<String> getAvailableMovesAsSanAndFilterByLegalMoves() {
    final currentNode = _parentNode[_currentNodeIndex];
    if (currentNode == null) return [];

    List<String> results = [];
    results.add(currentNode['halfMove']['notation']);

    if (currentNode['variations'].length > 0) {
      final variationsSan = currentNode['variations'].map((item) {
        final pgn = item['pgn'];
        return pgn.length > 0 ? pgn[0]['halfMove']['notation'] : null;
      }).where((item) => item != null);
      results.addAll(List<String>.from(variationsSan));
    }

    return results;
  }

  List<board_logic.Move> getMoveListFromSanList(List<String> sanList) {
    final legalMoves = _boardState.generate_moves({'legal': true});
    final legalSanList = legalMoves.map((currentMove) {
      return _boardState.move_to_san(currentMove);
    }).toList();

    return sanList.map((inputSan) {
      final int matchingLegalSanIndex = legalSanList.indexWhere((legalSan) {
        return legalSan == inputSan;
      });
      if (matchingLegalSanIndex != null)
        return legalMoves[matchingLegalSanIndex];
      else
        return null;
    }).toList();
  }

  Future<void> startNewGame(BuildContext context) async {
    final boardNotEmpty = _boardState.fen != EMPTY_BOARD;
    if (boardNotEmpty) {
      final confirmed = await showOkCancelAlertDialog(
        context: context,
        title: AppLocalizations.of(context).newGameDialogTitle,
        message: AppLocalizations.of(context).newGameDialogMessage,
        okLabel: AppLocalizations.of(context).yesButton,
        cancelLabel: AppLocalizations.of(context).noButton,
      );
      if (confirmed == OkCancelResult.ok) return await loadPgn(context);
    } else {
      return await loadPgn(context);
    }
  }

  Future<void> stopCurrentGame(BuildContext contex) async {
    if (_gameInProgress) {
      final confirmed = await showOkCancelAlertDialog(
        context: context,
        title: AppLocalizations.of(context).stopGameDialogTitle,
        message: AppLocalizations.of(context).stopGameDialogMessage,
        okLabel: AppLocalizations.of(context).yesButton,
        cancelLabel: AppLocalizations.of(context).noButton,
      );
      if (confirmed == OkCancelResult.ok) {
        setState(() {
          _gameInProgress = false;
          tryToGoToLastItem();
          Toast.show(AppLocalizations.of(context).gameStopped, context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        });
      }
    }
  }

  Future<void> handleDragReleased(
      String startCellStr, String endCellStr) async {
    var boardLogicClone = board_logic.Chess();
    boardLogicClone.load(_boardState.fen);
    final legalMove = boardLogicClone
        .move({'from': startCellStr, 'to': endCellStr, 'promotion': 'q'});
    if (legalMove) {
      final startCell = Cell.fromAlgebraic(startCellStr);
      final endCell = Cell.fromAlgebraic(endCellStr);
      final isPawn =
          _boardState.get(startCellStr).type == board_logic.PieceType.PAWN;
      final isWhitePromotion = _boardState.turn == board_logic.Color.WHITE &&
          startCell.rank == 6 &&
          endCell.rank == 7;
      final isBlackPromotion = _boardState.turn == board_logic.Color.BLACK &&
          startCell.rank == 1 &&
          endCell.rank == 0;
      final isPromotion = isPawn && (isWhitePromotion || isBlackPromotion);

      if (isPromotion) {
        setState(() {
          _pendingPromotion = true;
          _pendingPromotionMove = Move(startCell, endCell);
        });
        return null;
      } else {
        final move = chess_utils.findMoveForPosition(
            _boardState, startCellStr, endCellStr, null);

        final moveSan = _boardState.move_to_san(move);
        final moveFan = chess_utils.moveFanFromMoveSan(
            moveSan, _boardState.turn == board_logic.Color.WHITE);

        try {
          await commitSingleMove(move, moveSan, moveFan);
        } catch (ex) {
          await handleUnexpectedMove(context, ex);
        }
      }
    }
  }

  updateCurrentNode(String moveSan, String moveFan) {
    final moveIndex = getMoveIndexFromExpectedMovesList(moveSan);

    setState(() {
      if (moveIndex == 0) {
        _currentNodeIndex++;
      } else {
        _parentNode =
            _parentNode[_currentNodeIndex]['variations'][moveIndex - 1]['pgn'];
        _currentNodeIndex = 1;
      }

      final noMoreMove = _currentNodeIndex >= _parentNode.length;
      if (noMoreMove) {
        _gameInProgress = false;
        tryToGoToLastItem();
        if (_whiteMode == PlayerMode.GuessMove ||
            _blackMode == PlayerMode.GuessMove) {
          congratUser();
        }
      }
    });
  }

  Future<void> congratUser() async {
    return await showOkAlertDialog(
      context: context,
      okLabel: AppLocalizations.of(context).okButton,
      title: AppLocalizations.of(context).userCongratulationTitle,
      message: AppLocalizations.of(context).userCongratulationMessage,
    );
  }

  cancelPendingPromotion() {
    setState(() {
      _pendingPromotionMove = null;
      _pendingPromotion = false;
    });
  }

  int getMoveIndexFromExpectedMovesList(String moveSan) {
    final expectedMoves = getAvailableMovesAsSanAndFilterByLegalMoves();
    final moveIndex =
        expectedMoves.indexWhere((currentMove) => currentMove == moveSan);
    if (moveIndex < 0) {
      final moveFan = chess_utils.moveFanFromMoveSan(
          moveSan, _boardState.turn == board_logic.Color.BLACK);
      final expectedMovesFanList = expectedMoves
          .map((currentSan) => chess_utils.moveFanFromMoveSan(
              currentSan, _boardState.turn == board_logic.Color.BLACK))
          .toList();
      throw UnexpectedMoveException(moveFan, expectedMovesFanList);
    }
    return moveIndex;
  }

  Future<void> commitPromotionMove(String type) async {
    final move = chess_utils.findMoveForPosition(
        _boardState,
        _pendingPromotionMove.start.toAlgebraic(),
        _pendingPromotionMove.end.toAlgebraic(),
        type);

    final moveSan = _boardState.move_to_san(move);
    final moveFan = chess_utils.moveFanFromMoveSan(
        moveSan, _boardState.turn == board_logic.Color.WHITE);

    _boardState.move(move);

    processMoveFanIntoHistoryWidgetMoves(
        moveFan, _boardState.turn != board_logic.Color.WHITE);

    setState(() {
      _lastMoveVisible = true;
      _lastMoveStartFile = _pendingPromotionMove.start.file;
      _lastMoveStartRank = _pendingPromotionMove.start.rank;
      _lastMoveEndFile = _pendingPromotionMove.end.file;
      _lastMoveEndRank = _pendingPromotionMove.end.rank;
    });
    cancelPendingPromotion();

    try {
      updateCurrentNode(moveSan, moveFan);

      await tryToMakeComputerPlayRandomMove();
      return await letUserChooserNextMoveIfAppropriate();
    } catch (ex) {
      return await handleUnexpectedMove(context, ex);
    }
  }

  clearLastMoveArrow() {
    setState(() {
      _lastMoveVisible = false;
      _lastMoveStartFile = -10;
      _lastMoveStartRank = -10;
      _lastMoveEndFile = -10;
      _lastMoveEndRank = -10;
    });
  }

  tryToSetPositionBasedOnCurrentItemIndex() {
    if (_selectedHistoryItemIndex >= 0 &&
        _selectedHistoryItemIndex < _historyWidgetContent.length) {
      final item = _historyWidgetContent[_selectedHistoryItemIndex];

      if (item.fenAfterMove != null) {
        tryToSetHistoryPosition(
          fen: item.fenAfterMove,
          lastMoveStartFile: item.lastMoveStartFile,
          lastMoveStartRank: item.lastMoveStartRank,
          lastMoveEndFile: item.lastMoveEndFile,
          lastMoveEndRank: item.lastMoveEndRank,
        );
      }
    }
  }

  void tryToSetStartPosition() {
    tryToSetHistoryPosition(
      fen: _startPosition,
      lastMoveStartFile: null,
      lastMoveStartRank: null,
      lastMoveEndFile: null,
      lastMoveEndRank: null,
    );
  }

  void tryToSetHistoryPosition(
      {String fen,
      int lastMoveStartFile,
      int lastMoveStartRank,
      int lastMoveEndFile,
      int lastMoveEndRank}) {
    if (!_gameInProgress) {
      if (fen != null) {
        setState(() {
          _boardState = board_logic.Chess();
          _boardState.load(fen);
          _lastMoveStartFile = lastMoveStartFile;
          _lastMoveStartRank = lastMoveStartRank;
          _lastMoveEndFile = lastMoveEndFile;
          _lastMoveEndRank = lastMoveEndRank;
        });
      } else {
        setState(() {
          _boardState = board_logic.Chess();
          _boardState.load(_startPosition);
          _lastMoveStartFile = null;
          _lastMoveStartRank = null;
          _lastMoveEndFile = null;
          _lastMoveEndRank = null;
        });
      }
    }
  }

  Future<void> handleUnexpectedMove(
      BuildContext context, UnexpectedMoveException ex) async {
    setState(() {
      _gameInProgress = false;
      tryToGoToLastItem();
    });
    await showOkAlertDialog(
      context: context,
      okLabel: AppLocalizations.of(context).okButton,
      message: AppLocalizations.of(context)
          .badMoveMessage(ex.moveFan, ex.expectedMovesFanList),
      title: AppLocalizations.of(context).badMoveTitle,
    );
  }

  List<Widget> buildAboutChildren() {
    List<String> inputs = <String>[
      'Laurent Bernabé',
      '2021',
      '',
      AppLocalizations.of(context).appDescription,
      '',
      AppLocalizations.of(context).creditsSection,
    ];
    List<Widget> results = inputs
        .map(
          (inputText) => Text(
            inputText,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        )
        .toList();
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    final minSize =
        viewport.width < viewport.height ? viewport.width : viewport.height;

    final isDarkMode = Provider.of<DarkModeManager>(context).isActive;

    final spinKit = _loading
        ? SpinKitWave(
            itemBuilder: (BuildContext context, int index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
              );
            },
            size: 50.0,
          )
        : null;

    List<Widget> children = <Widget>[
      Column(
        children: <Widget>[
          HeaderBar(
              width: viewport.width * 0.8,
              height: viewport.height * 0.1,
              startGame: () async => await startNewGame(context),
              stopGame: () async => await stopCurrentGame(context),
              reverseBoard: () {
                setState(() {
                  _boardReversed = !_boardReversed;
                });
              }),
          GoalLabel(goalString: _goalString, fontSize: minSize * 0.03),
          GameComponents(
            selectedItemIndex: _selectedHistoryItemIndex,
            startPosition: _startPosition,
            blackAtBottom: _boardReversed,
            commonSize: minSize * 0.65,
            fen: _boardState.fen,
            userCanMovePieces: shouldChessBoardBetInteractive(),
            hasPendingPromotion: _pendingPromotion,
            lastMoveVisible: _lastMoveVisible,
            lastMoveStartFile: _lastMoveStartFile,
            lastMoveStartRank: _lastMoveStartRank,
            lastMoveEndFile: _lastMoveEndFile,
            lastMoveEndRank: _lastMoveEndRank,
            onDragReleased: (startCellStr, endCellStr) async {
              await handleDragReleased(startCellStr, endCellStr);
            },
            commitPromotionMove: (pieceType) async {
              await commitPromotionMove(pieceType);
            },
            cancelPendingPromotion: cancelPendingPromotion,
            historyWidgetContent: _historyWidgetContent,
            reactivityEnabled: !_gameInProgress && _startPosition != null,
            handleHistoryPositionRequested: tryToSetHistoryPosition,
            handleHistoryItemRequested: (index) {
              setState(() {
                _selectedHistoryItemIndex = index;
                tryToSetPositionBasedOnCurrentItemIndex();
              });
            },
            handleHistoryGotoFirstItemRequested: () {
              tryToGoToFirstItem();
            },
            handleHistoryGotoPreviousItemRequested: () {
              tryToGoToPreviousItem();
            },
            handleHistoryGotoNextItemRequested: () {
              tryToGoToNextItem();
            },
            handleHistoryGotoLastItemRequested: () {
              tryToGoToLastItem();
            },
          ),
          BottomBar(
            gameInProgress: _gameInProgress,
            whiteMode: _whiteMode,
            blackMode: _blackMode,
          )
        ],
      ),
    ];

    if (spinKit != null) children.add(spinKit);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).gamePageTitle,
        ),
        actions: <Widget>[
          TextButton.icon(
            label: Text(''),
            icon: Image(
              image: AssetImage('images/info.png'),
              width: 40.0,
              height: 40.0,
            ),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Chess Pgn reviser',
                applicationVersion: '1.0.0',
                children: buildAboutChildren(),
              );
            },
          ),
          ToggleButtons(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            isSelected: _darkModeButtonsSelection,
            onPressed: (int index) {
              setState(
                () {
                  for (int buttonIndex = 0;
                      buttonIndex < _darkModeButtonsSelection.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      _darkModeButtonsSelection[buttonIndex] = true;
                    } else {
                      _darkModeButtonsSelection[buttonIndex] = false;
                    }
                  }

                  Provider.of<DarkModeManager>(context, listen: false)
                      .setActive(_darkModeButtonsSelection[1]);
                },
              );
            },
            children: <Widget>[
              TextButton.icon(
                onPressed: null,
                icon: Image(
                  image: AssetImage('images/sun.png'),
                  width: 40.0,
                  height: 40.0,
                ),
                label: Text(''),
              ),
              TextButton.icon(
                onPressed: null,
                icon: Image(
                  image: AssetImage('images/night.png'),
                  width: 40.0,
                  height: 40.0,
                ),
                label: Text(''),
              ),
            ],
            fillColor: isDarkMode ? Colors.blue : Colors.green,
          ),
          SizedBox(
            width: 50.0,
          )
        ],
      ),
      body: Center(
        child: Stack(children: children),
      ),
    );
  }

  void tryToGoToFirstItem() {
    setState(() {
      _selectedHistoryItemIndex = -1;
      tryToSetStartPosition();
    });
  }

  void tryToGoToPreviousItem() {
    setState(
      () {
        if (_selectedHistoryItemIndex > 1) {
          do {
            _selectedHistoryItemIndex--;
          } while (_selectedHistoryItemIndex >= 0 &&
              _historyWidgetContent[_selectedHistoryItemIndex].fenAfterMove ==
                  null);
          tryToSetPositionBasedOnCurrentItemIndex();
        } else if (_selectedHistoryItemIndex == 1) {
          _selectedHistoryItemIndex = -1;
          tryToSetStartPosition();
        }
      },
    );
  }

  void tryToGoToNextItem() {
    final noMove = _historyWidgetContent.length < 2;
    if (noMove) return;
    if (_selectedHistoryItemIndex < _historyWidgetContent.length - 1) {
      setState(() {
        try {
          do {
            _selectedHistoryItemIndex++;
          } while (
              _historyWidgetContent[_selectedHistoryItemIndex].fenAfterMove ==
                  null);
        } on RangeError {
          // We must get backward to the last move (last node with a fen defined)
          do {
            _selectedHistoryItemIndex--;
          } while (
              _historyWidgetContent[_selectedHistoryItemIndex].fenAfterMove ==
                  null);
        }
        tryToSetPositionBasedOnCurrentItemIndex();
      });
    }
  }

  void tryToGoToLastItem() {
    final noMove = _historyWidgetContent.length < 2;
    if (noMove) return;
    setState(() {
      _selectedHistoryItemIndex = _historyWidgetContent.length - 1;
      while (_historyWidgetContent[_selectedHistoryItemIndex].fenAfterMove ==
          null) {
        _selectedHistoryItemIndex--;
      }
      tryToSetPositionBasedOnCurrentItemIndex();
    });
  }
}

class GameComponents extends StatelessWidget {
  final double commonSize;
  final bool blackAtBottom;
  final String fen;
  final bool userCanMovePieces;
  final bool hasPendingPromotion;
  final bool lastMoveVisible;
  final int lastMoveStartFile;
  final int lastMoveStartRank;
  final int lastMoveEndFile;
  final int lastMoveEndRank;
  final void Function(String startCell, String endCell) onDragReleased;
  final void Function(String pieceType) commitPromotionMove;
  final void Function() cancelPendingPromotion;
  final List<HistoryItem> historyWidgetContent;
  final bool reactivityEnabled;
  final String startPosition;
  final int selectedItemIndex;
  final void Function(
      {String fen,
      int lastMoveStartFile,
      int lastMoveStartRank,
      int lastMoveEndFile,
      int lastMoveEndRank}) handleHistoryPositionRequested;

  final void Function(int index) handleHistoryItemRequested;
  final void Function() handleHistoryGotoFirstItemRequested;
  final void Function() handleHistoryGotoPreviousItemRequested;
  final void Function() handleHistoryGotoNextItemRequested;
  final void Function() handleHistoryGotoLastItemRequested;

  GameComponents(
      {@required this.commonSize,
      @required this.blackAtBottom,
      @required this.fen,
      @required this.userCanMovePieces,
      @required this.hasPendingPromotion,
      @required this.lastMoveVisible,
      @required this.lastMoveStartFile,
      @required this.lastMoveStartRank,
      @required this.lastMoveEndFile,
      @required this.lastMoveEndRank,
      @required this.onDragReleased,
      @required this.commitPromotionMove,
      @required this.cancelPendingPromotion,
      @required this.historyWidgetContent,
      @required this.reactivityEnabled,
      @required this.startPosition,
      @required this.selectedItemIndex,
      this.handleHistoryPositionRequested,
      this.handleHistoryItemRequested,
      this.handleHistoryGotoFirstItemRequested,
      this.handleHistoryGotoPreviousItemRequested,
      this.handleHistoryGotoNextItemRequested,
      this.handleHistoryGotoLastItemRequested});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        board.ChessBoard(
          fen: fen,
          size: commonSize,
          userCanMovePieces: userCanMovePieces,
          onDragReleased: onDragReleased,
          blackAtBottom: blackAtBottom,
          lastMoveVisible: lastMoveVisible,
          lastMoveStartFile: lastMoveStartFile,
          lastMoveStartRank: lastMoveStartRank,
          lastMoveEndFile: lastMoveEndFile,
          lastMoveEndRank: lastMoveEndRank,
          pendingPromotion: hasPendingPromotion,
          commitPromotionMove: commitPromotionMove,
          cancelPendingPromotion: cancelPendingPromotion,
        ),
        HistoryWidget(
          handleHistoryItemRequested: handleHistoryItemRequested,
          handleHistoryGotoFirstItemRequested:
              handleHistoryGotoFirstItemRequested,
          handleHistoryGotoPreviousItemRequested:
              handleHistoryGotoPreviousItemRequested,
          handleHistoryGotoNextItemRequested:
              handleHistoryGotoNextItemRequested,
          handleHistoryGotoLastItemRequested:
              handleHistoryGotoLastItemRequested,
          selectedItemIndex: selectedItemIndex,
          width: commonSize,
          height: commonSize,
          content: historyWidgetContent,
          reactivityEnabled: reactivityEnabled,
          handleHistoryPositionRequested: handleHistoryPositionRequested,
          startPosition: startPosition,
        )
      ],
    );
  }
}

class GoalLabel extends StatelessWidget {
  const GoalLabel({
    @required this.goalString,
    @required this.fontSize,
  });

  final String goalString;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      goalString,
      style: TextStyle(fontSize: fontSize),
    );
  }
}
