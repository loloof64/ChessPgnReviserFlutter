// @dart=2.9
import 'package:flutter/material.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

class ChessBoardPromotionZoneWhite extends StatelessWidget {
  final double size;
  final Function(String pieceType) commitPromotionMove;
  final Function() cancelPendingPromotion;

  ChessBoardPromotionZoneWhite(
      {@required this.size,
      @required this.commitPromotionMove,
      @required this.cancelPendingPromotion});

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
              icon: WhiteQueen(
                size: promotionPieceSize,
              ),
              onPressed: () {
                if (commitPromotionMove != null) commitPromotionMove('q');
              },
            ),
            TextButton.icon(
              label: Text(''),
              icon: WhiteRook(
                size: promotionPieceSize,
              ),
              onPressed: () {
                if (commitPromotionMove != null) commitPromotionMove('r');
              },
            ),
            TextButton.icon(
              label: Text(''),
              icon: WhiteBishop(
                size: promotionPieceSize,
              ),
              onPressed: () {
                if (commitPromotionMove != null) commitPromotionMove('b');
              },
            ),
            TextButton.icon(
              label: Text(''),
              icon: WhiteKnight(
                size: promotionPieceSize,
              ),
              onPressed: () {
                if (commitPromotionMove != null) commitPromotionMove('n');
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
                if (cancelPendingPromotion != null) cancelPendingPromotion();
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
