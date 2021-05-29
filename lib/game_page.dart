// @dart=2.9
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as board_logic;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:petitparser/context.dart';
import 'package:toast/toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:chess_pgn_reviser/pgn_parser.dart';
import 'package:chess_pgn_reviser/game_selector.dart';
import 'package:chess_pgn_reviser/chessboard/chessboard.dart' as board;
import 'package:chess_pgn_reviser/chessboard/chessboard_types.dart';

class GamePage extends StatefulWidget {
  GamePage({Key key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var _boardState = board_logic.Chess();
  var _pendingPromotion = false;
  Move _pendingPromotionMove;
  var _boardReversed = false;
  var _lastMoveVisible = false;
  var _lastMoveStartFile = -10;
  var _lastMoveStartRank = -10;
  var _lastMoveEndFile = -10;
  var _lastMoveEndRank = -10;

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

      setState(() {
        _boardState = board_logic.Chess.fromFEN(fen);
        _boardReversed = game["moves"]["pgn"][0]["turn"] == "b";
      });
      clearLastMoveArrow();
    } catch (ex, stacktrace) {
      Completer().completeError(ex, stacktrace);
      Toast.show("Failed to read pgn content, cancelled new game !", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  startNewGame(BuildContext context) {
    loadPgn(context);
  }

  notifyGameFinishedIfNecessary() {
    if (_boardState.in_checkmate) {
      final actor =
          _boardState.turn == board_logic.Color.WHITE ? 'Blacks' : 'Whites';
      Toast.show("$actor have won by checkmate.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_boardState.in_stalemate) {
      Toast.show("Draw by stalemate.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_boardState.in_threefold_repetition) {
      Toast.show("Draw by three fold repetition.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_boardState.insufficient_material) {
      Toast.show("Draw by insufficient material.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_boardState.in_draw) {
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
        notifyGameFinishedIfNecessary();
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
    cancelPendingPromotion();
    setState(() {
      _lastMoveVisible = true;
      _lastMoveStartFile = _pendingPromotionMove.start.file;
      _lastMoveStartRank = _pendingPromotionMove.start.rank;
      _lastMoveEndFile = _pendingPromotionMove.end.file;
      _lastMoveEndRank = _pendingPromotionMove.end.rank;
    });
    notifyGameFinishedIfNecessary();
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

  Widget mainZone(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    final size = min(viewport.height * 0.6, viewport.width);
    final promotionPieceSize = size / 7.0;

    var children = <Widget>[
      board.ChessBoard(
        fen: _boardState.fen,
        size: size,
        onDragMove: (startCell, endCell) {
          checkAndMakeMove(startCell, endCell);
        },
        blackAtBottom: _boardReversed,
        lastMoveVisible: _lastMoveVisible,
        lastMoveStartFile: _lastMoveStartFile,
        lastMoveStartRank: _lastMoveStartRank,
        lastMoveEndFile: _lastMoveEndFile,
        lastMoveEndRank: _lastMoveEndRank,
      ),
    ];

    if (_pendingPromotion) {
      List<Widget> promotionButtons;
      if (_boardState.turn == board_logic.Color.WHITE) {
        promotionButtons = <Widget>[
          TextButton.icon(
            label: Text(''),
            icon: WhiteQueen(
              size: promotionPieceSize,
            ),
            onPressed: () {
              commitPromotionMove('q');
            },
          ),
          TextButton.icon(
            label: Text(''),
            icon: WhiteRook(
              size: promotionPieceSize,
            ),
            onPressed: () {
              commitPromotionMove('r');
            },
          ),
          TextButton.icon(
            label: Text(''),
            icon: WhiteBishop(
              size: promotionPieceSize,
            ),
            onPressed: () {
              commitPromotionMove('b');
            },
          ),
          TextButton.icon(
            label: Text(''),
            icon: WhiteKnight(
              size: promotionPieceSize,
            ),
            onPressed: () {
              commitPromotionMove('n');
            },
          ),
        ];
      } else {
        promotionButtons = <Widget>[
          TextButton.icon(
            label: Text(''),
            icon: BlackQueen(
              size: promotionPieceSize,
            ),
            onPressed: () {
              commitPromotionMove('q');
            },
          ),
          TextButton.icon(
            label: Text(''),
            icon: BlackRook(
              size: promotionPieceSize,
            ),
            onPressed: () {
              commitPromotionMove('r');
            },
          ),
          TextButton.icon(
            label: Text(''),
            icon: BlackBishop(
              size: promotionPieceSize,
            ),
            onPressed: () {
              commitPromotionMove('b');
            },
          ),
          TextButton.icon(
            label: Text(''),
            icon: BlackKnight(
              size: promotionPieceSize,
            ),
            onPressed: () {
              commitPromotionMove('n');
            },
          ),
        ];
      }
      children.insert(
          1,
          Opacity(
            opacity: 0.3,
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ...promotionButtons,
                  TextButton.icon(
                    label: Text(''),
                    icon: Image(
                      image: AssetImage('images/red_cross.png'),
                      width: promotionPieceSize,
                      height: promotionPieceSize,
                    ),
                    onPressed: () {
                      cancelPendingPromotion();
                    },
                  ),
                ],
              ),
              width: size,
              height: size,
              color: Colors.blue[600],
            ),
          ));
    }

    return Stack(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game page"),
      ),
      body: Center(
          child: Column(
        children: [
          headerBar(context),
          mainZone(context),
        ],
      )),
    );
  }
}
