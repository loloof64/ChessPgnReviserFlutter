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
import '../utils/chess_utils.dart';

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
      _checkPiecesCount(gameLogic);
      final moves = gameLogic.generate_moves();
      final noMoreMove = moves.isEmpty;

      if (noMoreMove) {
        throw Exception("Cannot load the position : no move can be made !");
      }

      setState(() {
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

  _checkPiecesCount(board_logic.Chess gameLogic) {
    final piecesCounts = Map<String, int>();
    for (var rank = 0; rank < 8; rank++) {
      for (var file = 0; file < 8; file++) {
        final cell = board_logic.Chess.algebraic(16 * rank + file);
        final currentPiece = gameLogic.get(cell);
        if (currentPiece != null) {
          final currentFen = pieceTypeToFen(currentPiece);
          if (piecesCounts.containsKey(currentFen)) {
            piecesCounts[currentFen] += 1;
          } else {
            piecesCounts[currentFen] = 1;
          }
        }
      }
    }

    if (!piecesCounts.containsKey('K')) {
      throw Exception("No white king !");
    }
    if (!piecesCounts.containsKey('k')) {
      throw Exception("No black king !");
    }

    if (piecesCounts['K'] != 1) {
      throw Exception("There must be exactly one white king !");
    }
    if (piecesCounts['k'] != 1) {
      throw Exception("There must be exactly one black king !");
    }

    if (piecesCounts.containsKey('K') && piecesCounts['K'] > 8)
      throw Exception("Too many white pawns !");
    if (piecesCounts.containsKey('k') && piecesCounts['k'] > 8)
      throw Exception("Too many black pawns !");

    if (piecesCounts.containsKey('N') && piecesCounts['N'] > 10)
      throw Exception("Too many white knights !");
    if (piecesCounts.containsKey('n') && piecesCounts['n'] > 10)
      throw Exception("Too many black knights !");

    if (piecesCounts.containsKey('B') && piecesCounts['B'] > 10)
      throw Exception("Too many white bishops !");
    if (piecesCounts.containsKey('b') && piecesCounts['b'] > 10)
      throw Exception("Too many black bishops !");

    if (piecesCounts.containsKey('R') && piecesCounts['R'] > 10)
      throw Exception("Too many white rooks !");
    if (piecesCounts.containsKey('r') && piecesCounts['r'] > 10)
      throw Exception("Too many black rooks !");

    if (piecesCounts.containsKey('Q') && piecesCounts['Q'] > 9)
      throw Exception("Too many white queens !");
    if (piecesCounts.containsKey('q') && piecesCounts['q'] > 9)
      throw Exception("Too many black queens !");
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

  checkAndMakeMove(String startCellStr, String endCellStr) {
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
      } else {
        _boardState.move({'from': startCellStr, 'to': endCellStr});
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
      }
    }
  }

  cancelPendingPromotion() {
    setState(() {
      _pendingPromotionMove = null;
      _pendingPromotion = false;
    });
  }

  commitPromotionMove(String type) {
    _boardState.move({
      'from': _pendingPromotionMove.start.toAlgebraic(),
      'to': _pendingPromotionMove.end.toAlgebraic(),
      'promotion': type
    });
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

  Widget headerBar(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    final commonHeight = viewport.height * 0.09;
    final commonPadding = 10.0;

    return Container(
      width: viewport.width * 0.8,
      height: viewport.height * 0.1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: Colors.teal[200],
      ),
      margin: EdgeInsets.all(viewport.height * 0.025),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: commonPadding),
            child: TextButton.icon(
              label: Text(''),
              icon: Image(
                image: AssetImage('images/racing_flag.png'),
                width: commonHeight,
                height: commonHeight,
              ),
              onPressed: () {
                startNewGame(context);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: commonPadding),
            child: TextButton.icon(
              label: Text(''),
              icon: Image(
                image: AssetImage('images/stop.png'),
                width: commonHeight,
                height: commonHeight,
              ),
              onPressed: () {
                stopCurrentGame(context);
              },
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: commonPadding),
              child: TextButton.icon(
                label: Text(''),
                icon: Image(
                  image: AssetImage('images/reverse_arrows.png'),
                  width: commonHeight,
                  height: commonHeight,
                ),
                onPressed: () {
                  setState(() {
                    _boardReversed = !_boardReversed;
                  });
                },
              )),
        ],
      ),
    );
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
          headerBar(context),
          Text(
            _goalString,
            style: TextStyle(fontSize: minSize * 0.04),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              board.ChessBoard(
                fen: _boardState.fen,
                size: minSize * 0.7,
                userCanMovePieces: _gameInProgress,
                onDragMove: (startCell, endCell) {
                  checkAndMakeMove(startCell, endCell);
                },
                blackAtBottom: _boardReversed,
                lastMoveVisible: _lastMoveVisible,
                lastMoveStartFile: _lastMoveStartFile,
                lastMoveStartRank: _lastMoveStartRank,
                lastMoveEndFile: _lastMoveEndFile,
                lastMoveEndRank: _lastMoveEndRank,
                pendingPromotion: _pendingPromotion,
                commitPromotionMove: (pieceType) =>
                    commitPromotionMove(pieceType),
                cancelPendingPromotion: () => cancelPendingPromotion(),
              ),
              HistoryWidget(
                width: minSize * 0.7,
                height: minSize * 0.7,
                content: ['1.', 'e4', 'e5', '2.', 'Nf3', 'Nc6', '3.', 'Bb5'],
              )
            ],
          ),
        ],
      )),
    );
  }
}
