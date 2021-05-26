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
import 'package:chess_pgn_reviser/pgn_parser.dart';

class GamePage extends StatefulWidget {
  GamePage({Key key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var _boardState = board_logic.Chess();
  var _pendingPromotion = false;
  board.ShortMove _pendingPromotionMove;

  loadPgn() {
    final content = '''
      [Event "Video #1 Mastering Rook Endings"]
      [Site "?"]
      [Date "2008.02.21"]
      [Round "?"]
      [White "Rook and Pawn Endings"]
      [Black "Lucena/Bridge Position"]
      [Result "*"]
      [SetUp "1"]
      [FEN "6K1/4k1P1/8/8/8/8/5R2/7r w - - 0 1"]
      [PlyCount "13"]
      [EventDate "2008.02.15"]
      
      1. Re2+ Kd7 (1... Kf6 2. Kf8 \$18 {Diagram #}) 2. Re4 Kd6 3. Kf7 {Diagram #}
      Rf1+ 4. Kg6 Rg1+ 5. Kf6 Rf1+ (5... Rg2 6. Re6+ (6. Re5 \$2 Rf2+ (6... Rxg7 \$1
      \$11) 7. Rf5 Rg2 8. Rg5 \$18) 6... Kd7 7. Re5 Rf2+ 8. Rf5 Rg2 9. Rg5 \$18) 6. Kg5
      Rg1+ {Diagram #} 7. Rg4 \$18 * 

[Event "Interclubs FRA"]
[Site "?"]
[Date "????.??.??"]
[Round "?"]
[White "Calistri, Tristan"]
[Black "Bauduin, Etienne"]
[Result "1-0"]

1.e4 c5 2.Nf3 e6 3.d4 cxd4 4.Nxd4 Nc6 5.Nc3 a6 6.Be2 Qc7 7.O-O Nf6 8.Be3 Bb4 
9.Na4 O-O 10.c4 Bd6 11.g3 Nxe4 12.Bf3 f5 13.Bxe4 fxe4 14.c5 Be7 {Les Noirs ont 
un pion d'avance mais de gros problèmes pour mettre leur Fc8 et leur Ta8 en jeu} 
15.Qg4 Ne5 16.Qxe4 d5 17.cxd6 Bxd6 18.Rac1 Qa5 19.Nb3 {Les blancs ont 
récupéré leur pion et toutes leurs pièces sont mobilisées}
19...Qb4 
    (19...Qd5 20.Qxd5 exd5 21.Nb6 Bh3 22.Nxa8 Nf3+ 23.Kh1 Bxf1 24.Rxf1 Rxa8 25.Rd1)
    (19...Nf3+ 20.Kg2 Qh5)
20.Qxb4 Bxb4 21.Nb6 \$18 {Les noirs n'arriveront jamais à sortir leur Fc8}
21...Rb8 22.Bc5 Bxc5 
    (22...Nd3 23.Bxf8 Nxc1 24.Rxc1 Bxf8 25.Rxc8 Rxc8 26.Nxc8)
23.Nxc5 Rd8 24.Rfd1 Re8 25.Ne4 Nf7 26.Rc7 Kf8 27.Rdc1 1-0
    ''';

    try {
      final definition = PgnParserDefinition();
      final parser = definition.build();
      final parseResult = parser.parse(content);

      final tempValue = parseResult.value;

      final result = tempValue is List && tempValue[0] is Failure<dynamic>
          ? tempValue.last
          : tempValue;

      final game = result[0];
      final fen = game["tags"]["FEN"] ?? board_logic.Chess().fen;

      setState(() {
        _boardState = board_logic.Chess.fromFEN(fen);
      });
    } catch (ex, stacktrace) {
      Completer().completeError(ex, stacktrace);
      Toast.show("Failed to read pgn content !", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  startNewGame() {
    loadPgn();
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

  Widget headerBar(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    final commonHeight = viewport.height * 0.09;

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
          TextButton.icon(
            label: Text(''),
            icon: Image(
              image: AssetImage('images/racing_flag.png'),
              width: commonHeight,
              height: commonHeight,
            ),
            onPressed: () {
              startNewGame();
            },
          ),
        ],
      ),
    );
  }

  Widget mainZone(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    final size = min(viewport.height * 0.7, viewport.width);
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
