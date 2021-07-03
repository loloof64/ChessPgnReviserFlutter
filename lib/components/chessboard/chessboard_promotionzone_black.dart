import 'package:flutter/material.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

class ChessBoardPromotionZoneBlack extends StatelessWidget {
  final double size;
  final Function(String pieceType)? commitPromotionMove;
  final Function()? cancelPendingPromotion;

  ChessBoardPromotionZoneBlack(
      {required this.size,
      this.commitPromotionMove,
      this.cancelPendingPromotion});

  @override
  Widget build(BuildContext context) {
    final promotionPieceSize = size / 7.0;

    return Opacity(
      opacity: 0.3,
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton.icon(
              label: Text(''),
              icon: BlackQueen(
                size: promotionPieceSize,
              ),
              onPressed: () {
                if (commitPromotionMove != null) commitPromotionMove?.call('q');
              },
            ),
            TextButton.icon(
              label: Text(''),
              icon: BlackRook(
                size: promotionPieceSize,
              ),
              onPressed: () {
                if (commitPromotionMove != null) commitPromotionMove?.call('r');
              },
            ),
            TextButton.icon(
              label: Text(''),
              icon: BlackBishop(
                size: promotionPieceSize,
              ),
              onPressed: () {
                if (commitPromotionMove != null) commitPromotionMove?.call('b');
              },
            ),
            TextButton.icon(
              label: Text(''),
              icon: BlackKnight(
                size: promotionPieceSize,
              ),
              onPressed: () {
                if (commitPromotionMove != null) commitPromotionMove?.call('n');
              },
            ),
            TextButton.icon(
              label: Text(''),
              icon: Image(
                image: AssetImage('images/red_cross.png'),
                width: promotionPieceSize,
                height: promotionPieceSize,
              ),
              onPressed: () {
                if (cancelPendingPromotion != null)
                  cancelPendingPromotion?.call();
              },
            ),
          ],
        ),
        width: size,
        height: size,
        color: Colors.blue[600],
      ),
    );
  }
}
