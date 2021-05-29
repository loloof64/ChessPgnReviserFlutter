// @dart=2.9
import 'package:flutter/material.dart';

import 'package:chess_pgn_reviser/chessboard/chessboard_wrapper.dart';
import 'package:chess_pgn_reviser/chessboard/chessboard_mainzone.dart';
import 'package:chess_pgn_reviser/chessboard/chessboard_promotionzone_white.dart';
import 'package:chess_pgn_reviser/chessboard/chessboard_promotionzone_black.dart';

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

  final bool pendingPromotion;

  final Function(String startCell, String endCell) onDragMove;

  final void Function() cancelPendingPromotion;
  final void Function(String pieceType) commitPromotionMove;

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
      this.userCanMovePieces,
      this.pendingPromotion,
      this.cancelPendingPromotion,
      this.commitPromotionMove});

  @override
  Widget build(BuildContext context) {
    final mainZoneSize = size * 0.88;
    final mainZonePadding = size * 0.06;
    final blackTurn = fen.split(" ")[1] == 'b';

    var stackChildren = <Widget>[
      ChessBoardMainZone(
        fen: fen,
        size: mainZoneSize,
        blackAtBottom: blackAtBottom,
        onMove: onDragMove,
        userCanMovePieces: userCanMovePieces,
      )
    ];

    if (pendingPromotion) {
      final blackTurn = fen.split(' ')[1] == 'b';
      stackChildren.add(blackTurn
          ? ChessBoardPromotionZoneBlack(
              size: size,
              cancelPendingPromotion: cancelPendingPromotion,
              commitPromotionMove: commitPromotionMove)
          : ChessBoardPromotionZoneWhite(
              size: size,
              cancelPendingPromotion: cancelPendingPromotion,
              commitPromotionMove: commitPromotionMove));
    }

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
            child: Stack(
              children: stackChildren,
            ),
          )
        ],
      ),
    );
  }
}
