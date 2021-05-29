// @dart=2.9
import 'package:flutter/material.dart';

import 'package:chess_pgn_reviser/chessboard/chessboard_wrapper.dart';
import 'package:chess_pgn_reviser/chessboard/chessboard_mainzone.dart';

class ChessBoard extends StatelessWidget {
  final double size;
  final bool blackAtBottom;
  final String fen;

  final bool lastMoveVisible;
  final int lastMoveStartFile;
  final int lastMoveStartRank;
  final int lastMoveEndFile;
  final int lastMoveEndRank;

  final bool userCanMovePieces;

  final Function(String startCell, String endCell) onDragMove;

  ChessBoard(
      {@required this.size,
      @required this.blackAtBottom,
      @required this.fen,
      this.lastMoveVisible,
      this.lastMoveStartFile,
      this.lastMoveStartRank,
      this.lastMoveEndFile,
      this.lastMoveEndRank,
      this.onDragMove,
      this.userCanMovePieces});

  @override
  Widget build(BuildContext context) {
    final mainZoneSize = size * 0.88;
    final mainZonePadding = size * 0.06;
    final blackTurn = fen.split(" ")[1] == 'b';

    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          ChessBoardWrapper(
            size: size,
            blackTurn: blackTurn,
            lastMoveVisible: lastMoveVisible,
            lastMoveStartFile: lastMoveStartFile,
            lastMoveStartRank: lastMoveStartRank,
            lastMoveEndFile: lastMoveEndFile,
            lastMoveEndRank: lastMoveEndRank,
            reversed: blackAtBottom,
          ),
          Padding(
            padding: EdgeInsets.all(mainZonePadding),
            child: ChessBoardMainZone(
              fen: fen,
              size: mainZoneSize,
              blackAtBottom: blackAtBottom,
              onMove: onDragMove,
              userCanMovePieces: userCanMovePieces,
            ),
          )
        ],
      ),
    );
  }
}
