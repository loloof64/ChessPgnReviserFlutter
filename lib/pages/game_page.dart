// @dart=2.9
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:chess/chess.dart' as board_logic;
import 'package:petitparser/context.dart';
import 'package:toast/toast.dart';
import 'package:file_selector/file_selector.dart';
import '../utils/pgn_parser/pgn_parser.dart';
import '../components/game_selector.dart';
import '../components/chessboard/chessboard.dart' as board;
import '../components/chessboard/chessboard_types.dart';
import '../components/history.dart';
import '../utils/chess_utils.dart' as chess_utils;
import '../components/header_bar.dart';

const EMPTY_BOARD = "8/8/8/8/8/8/8/8 w - - 0 1";

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
  int _lastMoveStartFile = -10;
  int _lastMoveStartRank = -10;
  int _lastMoveEndFile = -10;
  int _lastMoveEndRank = -10;
  String _goalString = "";
  bool _gameInProgress = false;
  List<String> _historyWidgetContent = [];

  processMoveSan(String moveSan, bool isWhiteTurn) {
    _historyWidgetContent.add(chess_utils.moveFanFromMoveSan(
      moveSan,
      isWhiteTurn,
    ));
  }

  String _getGameGoal(gamePgn) {
    final goalString = gamePgn["tags"]["Goal"] ?? "";
    if (goalString == "1-0") return "White should win";
    if (goalString == "0-1") return "Black should win";
    if (goalString.startsWith("1/2")) return "It should be draw";
    return goalString;
  }

  loadPgn(BuildContext context) async {
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
      Toast.show("Cancelled new game !", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }

    try {
      final content = await file.readAsString();
      final definition = PgnParserDefinition();
      final parser = definition.build();
      final parseResult = parser.parse(content);

      final tempValue = parseResult.value;

      final allGames = tempValue is List && tempValue[0] is Failure<dynamic>
          ? tempValue.last
          : tempValue;

      final gameIndex = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => GameSelector(allGames)));
      if (gameIndex == null) {
        Toast.show("Cancelled new game !", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
      final game = allGames[gameIndex];
      final fen = (game["tags"] ?? {})["FEN"] ?? board_logic.Chess().fen;

      final gameLogic = board_logic.Chess.fromFEN(fen);
      chess_utils.checkPiecesCount(gameLogic);
      final moves = gameLogic.generate_moves();
      final noMoreMove = moves.isEmpty;

      if (noMoreMove) {
        throw Exception("Cannot load the position : no move can be made !");
      }

      setState(() {
        _historyWidgetContent.clear();
        _goalString = _getGameGoal(game);
        _boardState = board_logic.Chess.fromFEN(fen);
        _boardReversed = fen.split(" ")[1] == "b";
        _gameInProgress = true;
      });
      clearLastMoveArrow();
    } catch (ex, stacktrace) {
      Completer().completeError(ex, stacktrace);
      Toast.show("Failed to read pgn content, cancelled new game !", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  startNewGame(BuildContext context) async {
    final boardNotEmpty = _boardState.fen != EMPTY_BOARD;
    if (boardNotEmpty) {
      if (await confirm(
        context,
        title: Text('Start new game ?'),
        content:
            Text('Do you want to start a new game and leave the current one ?'),
        textOK: Text('Yes'),
        textCancel: Text('No'),
      )) {
        loadPgn(context);
      }
    } else {
      loadPgn(context);
    }
  }

  stopCurrentGame(BuildContext contex) async {
    if (_gameInProgress) {
      if (await confirm(
        context,
        title: Text('Stop current game ?'),
        content: Text('Do you want to start stop current game ?'),
        textOK: Text('Yes'),
        textCancel: Text('No'),
      )) {
        setState(() {
          _gameInProgress = false;
          Toast.show("Game stopped.", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        });
      }
    }
  }

  handleGameFinishedIfNecessary() {
    if (_boardState.in_checkmate) {
      setState(() {
        _gameInProgress = false;
      });
      final actor =
          _boardState.turn == board_logic.Color.WHITE ? 'Blacks' : 'Whites';
      Toast.show("$actor have won by checkmate.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_boardState.in_stalemate) {
      setState(() {
        _gameInProgress = false;
      });
      Toast.show("Draw by stalemate.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_boardState.in_threefold_repetition) {
      setState(() {
        _gameInProgress = false;
      });
      Toast.show("Draw by three fold repetition.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_boardState.insufficient_material) {
      setState(() {
        _gameInProgress = false;
      });
      Toast.show("Draw by insufficient material.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_boardState.in_draw) {
      setState(() {
        _gameInProgress = false;
      });
      Toast.show("Draw by 50-moves rule.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  String checkAndMakeMove(String startCellStr, String endCellStr) {
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
        _boardState.move(move);

        final startCell = Cell.fromAlgebraic(startCellStr);
        final endCell = Cell.fromAlgebraic(endCellStr);
        setState(() {
          _lastMoveVisible = true;
          _lastMoveStartFile = startCell.file;
          _lastMoveStartRank = startCell.rank;
          _lastMoveEndFile = endCell.file;
          _lastMoveEndRank = endCell.rank;
        });
        handleGameFinishedIfNecessary();

        return moveSan;
      }
    }
    return null;
  }

  cancelPendingPromotion() {
    setState(() {
      _pendingPromotionMove = null;
      _pendingPromotion = false;
    });
  }

  commitPromotionMove(String type) {
    final move = chess_utils.findMoveForPosition(
        _boardState,
        _pendingPromotionMove.start.toAlgebraic(),
        _pendingPromotionMove.end.toAlgebraic(),
        type);
    final moveSan = _boardState.move_to_san(move);
    _boardState.move(move);

    if (moveSan != null)
      processMoveSan(moveSan, _boardState.turn != board_logic.Color.WHITE);

    setState(() {
      _lastMoveVisible = true;
      _lastMoveStartFile = _pendingPromotionMove.start.file;
      _lastMoveStartRank = _pendingPromotionMove.start.rank;
      _lastMoveEndFile = _pendingPromotionMove.end.file;
      _lastMoveEndRank = _pendingPromotionMove.end.rank;
    });
    cancelPendingPromotion();
    handleGameFinishedIfNecessary();
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

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    final minSize =
        viewport.width < viewport.height ? viewport.width : viewport.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Game page"),
      ),
      body: Center(
          child: Column(
        children: [
          HeaderBar(
              width: viewport.width * 0.8,
              height: viewport.height * 0.1,
              startGame: () => startNewGame(context),
              stopGame: () => stopCurrentGame(context),
              reverseBoard: () {
                setState(() {
                  _boardReversed = !_boardReversed;
                });
              }),
          GoalLabel(goalString: _goalString, minSize: minSize),
          GameComponents(
            blackAtBottom: _boardReversed,
            commonSize: minSize * 0.7,
            fen: _boardState.fen,
            userCanMovePieces: _gameInProgress,
            hasPendingPromotion: _pendingPromotion,
            lastMoveVisible: _lastMoveVisible,
            lastMoveStartFile: _lastMoveStartFile,
            lastMoveStartRank: _lastMoveStartRank,
            lastMoveEndFile: _lastMoveEndFile,
            lastMoveEndRank: _lastMoveEndRank,
            onDragMove: (startCell, endCell) {
              final moveSan = checkAndMakeMove(startCell, endCell);
              if (moveSan != null)
                processMoveSan(
                    moveSan, _boardState.turn != board_logic.Color.WHITE);
            },
            commitPromotionMove: (pieceType) => commitPromotionMove(pieceType),
            cancelPendingPromotion: cancelPendingPromotion,
            historyWidgetContent: _historyWidgetContent,
          ),
        ],
      )),
    );
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
  final Function onDragMove;
  final Function commitPromotionMove;
  final Function cancelPendingPromotion;
  final List<String> historyWidgetContent;

  GameComponents({
    @required this.commonSize,
    @required this.blackAtBottom,
    @required this.fen,
    @required this.userCanMovePieces,
    @required this.hasPendingPromotion,
    @required this.lastMoveVisible,
    @required this.lastMoveStartFile,
    @required this.lastMoveStartRank,
    @required this.lastMoveEndFile,
    @required this.lastMoveEndRank,
    @required this.onDragMove,
    @required this.commitPromotionMove,
    @required this.cancelPendingPromotion,
    @required this.historyWidgetContent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        board.ChessBoard(
          fen: fen,
          size: commonSize,
          userCanMovePieces: userCanMovePieces,
          onDragMove: onDragMove,
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
          width: commonSize,
          height: commonSize,
          content: historyWidgetContent,
        )
      ],
    );
  }
}

class GoalLabel extends StatelessWidget {
  const GoalLabel({
    @required this.goalString,
    @required this.minSize,
  });

  final String goalString;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      goalString,
      style: TextStyle(fontSize: minSize * 0.04),
    );
  }
}
