// @dart=2.9
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as board_logic;
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart'
    as board;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:petitparser/context.dart';
import 'package:toast/toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:chess_pgn_reviser/pgn_parser.dart';
import 'package:chess_pgn_reviser/game_selector.dart';
import 'package:chess_pgn_reviser/chessboard_coordinates.dart';
import 'package:chess_pgn_reviser/chessboard_lastmovearrow.dart';

class GamePage extends StatefulWidget {
  GamePage({Key key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var _boardState = board_logic.Chess();
  var _pendingPromotion = false;
  var _boardReversed = false;
  board.ShortMove _pendingPromotionMove;
  var _lastMoveVisible = false;
  var _lastMoveStartFile = -10;
  var _lastMoveStartRank = -10;
  var _lastMoveEndFile = -10;
  var _lastMoveEndRank = -10;
  var _lastMoveArrowBlinkingStarted = false;

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
        _lastMoveArrowBlinkingStarted = false;
        _lastMoveVisible = false;
        _lastMoveStartFile = -10;
        _lastMoveStartRank = -10;
        _lastMoveEndFile = -10;
        _lastMoveEndRank = -10;
        _boardState = board_logic.Chess.fromFEN(fen);
        _boardReversed = game["moves"]["pgn"][0]["turn"] == "b";
      });
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

  checkAndMakeMove(board.ShortMove move) {
    var boardLogicClone = board_logic.Chess();
    boardLogicClone.load(_boardState.fen);
    final legalMove = boardLogicClone
        .move({'from': move.from, 'to': move.to, 'promotion': 'q'});
    if (legalMove) {
      final isPawn =
          _boardState.get(move.from).type == board_logic.PieceType.PAWN;
      final isWhitePromotion = _boardState.turn == board_logic.Color.WHITE &&
          move.from.characters.elementAt(1) == "7" &&
          move.to.characters.elementAt(1) == "8";
      final isBlackPromotion = _boardState.turn == board_logic.Color.BLACK &&
          move.from.characters.elementAt(1) == "2" &&
          move.to.characters.elementAt(1) == "1";
      final isPromotion = isPawn && (isWhitePromotion || isBlackPromotion);

      if (isPromotion) {
        setState(() {
          _pendingPromotion = true;
          _pendingPromotionMove = move;
        });
      } else {
        _boardState.move({'from': move.from, 'to': move.to});
        setState(() {
          _lastMoveStartFile = move.from.codeUnitAt(0) - 'a'.codeUnitAt(0);
          _lastMoveStartRank = move.from.codeUnitAt(1) - '1'.codeUnitAt(0);
          _lastMoveEndFile = move.to.codeUnitAt(0) - 'a'.codeUnitAt(0);
          _lastMoveEndRank = move.to.codeUnitAt(1) - '1'.codeUnitAt(0);
        });
        if (!_lastMoveArrowBlinkingStarted) {
          setState(() {
            _lastMoveArrowBlinkingStarted = true;
          });
          blinkLastMoveArrowIn();
        }
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
      'from': _pendingPromotionMove.from,
      'to': _pendingPromotionMove.to,
      'promotion': type
    });
    setState(() {
      _lastMoveStartFile =
          _pendingPromotionMove.from.codeUnitAt(0) - 'a'.codeUnitAt(0);
      _lastMoveStartRank =
          _pendingPromotionMove.from.codeUnitAt(1) - '1'.codeUnitAt(0);
      _lastMoveEndFile =
          _pendingPromotionMove.to.codeUnitAt(0) - 'a'.codeUnitAt(0);
      _lastMoveEndRank =
          _pendingPromotionMove.to.codeUnitAt(1) - '1'.codeUnitAt(0);
    });
    if (!_lastMoveArrowBlinkingStarted) {
      setState(() {
        _lastMoveArrowBlinkingStarted = true;
      });
      blinkLastMoveArrowIn();
    }
    cancelPendingPromotion();
    notifyGameFinishedIfNecessary();
  }

  blinkLastMoveArrowIn() async {
    if (!_lastMoveArrowBlinkingStarted) return;
    setState(() {
      _lastMoveVisible = true;
    });

    Future.delayed(Duration(milliseconds: 700), () => blinkLastMoveArrowOut());
  }

  blinkLastMoveArrowOut() async {
    if (!_lastMoveArrowBlinkingStarted) return;
    setState(() {
      _lastMoveVisible = false;
    });

    Future.delayed(Duration(milliseconds: 1100), () => blinkLastMoveArrowIn());
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

    var mainZoneChildren = <Widget>[
      board.Chessboard(
        fen: _boardState.fen,
        size: size,
        onMove: (move) {
          checkAndMakeMove(move);
        },
        orientation: _boardReversed ? board.Color.BLACK : board.Color.WHITE,
      ),
    ];

    if (_lastMoveVisible) {
      mainZoneChildren.add(ChessBoardLastMoveArrow(
        size: size,
        visible: _lastMoveVisible,
        reversed: _boardReversed,
        startFile: _lastMoveStartFile,
        startRank: _lastMoveStartRank,
        endFile: _lastMoveEndFile,
        endRank: _lastMoveEndRank,
      ));
    }

    var children = <Widget>[
      Stack(
        children: [
          ChessBoardCoordinates(
            size: size * 1.11,
            reversed: _boardReversed,
            blackTurn: _boardState.turn == board_logic.Color.BLACK,
          ),
          Padding(
              padding: EdgeInsets.all(size * 0.055),
              child: Stack(children: mainZoneChildren)),
        ],
      )
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
