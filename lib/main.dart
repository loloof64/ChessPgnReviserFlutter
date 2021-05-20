// @dart=2.9
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as board_logic;
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart'
    as board;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:toast/toast.dart';

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
      home: MyHomePage(title: 'Game page'),
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
  var _boardState = board_logic.Chess();
  var _pendingPromotion = false;
  board.ShortMove _pendingPromotionMove;

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
          // We need to notify that state has been updated.
          // Nothing to add here.
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
      'from': _pendingPromotionMove.from,
      'to': _pendingPromotionMove.to,
      'promotion': type
    });
    setState(() {
      // We need to notify that state has been updated.
      // Nothing to add here.
    });
    cancelPendingPromotion();
    notifyGameFinishedIfNecessary();
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    final size = min(viewport.height * 0.8, viewport.width);
    final promotionPieceSize = size / 7.0;

    var children = <Widget>[
      board.Chessboard(
          fen: _boardState.fen,
          size: size,
          onMove: (move) {
            checkAndMakeMove(move);
          })
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: children,
        ),
      ),
    );
  }
}
