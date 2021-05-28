// @dart=2.9
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';

class ChessBoardCoordinates extends StatelessWidget {
  final double size;
  final bool reversed;
  final bool blackTurn;

  ChessBoardCoordinates({@required this.size, this.reversed, this.blackTurn});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: ChessBoardCoordinatesPainter(reversed, size, blackTurn),
    );
  }
}

class ChessBoardCoordinatesPainter extends CustomPainter {
  final bool reversed;
  final double size;
  final bool blackTurn;

  ChessBoardCoordinatesPainter(this.reversed, this.size, this.blackTurn);

  @override
  void paint(Canvas canvas, Size size) {
    final minSize = size.width < size.height ? size.width : size.height;
    final cellSize = minSize * 0.112;

    final backgroundPaint = Paint()..color = Colors.pinkAccent.shade400;
    final rect = Offset.zero & size;
    canvas.drawRect(rect, backgroundPaint);

    final textStyle = TextStyle(
      color: Colors.yellowAccent.shade700,
      fontSize: cellSize * 0.3,
    );

    for (var col in range(8)) {
      final x = cellSize * (0.9 + col);
      final y1 = cellSize * 0.05;
      final y2 = cellSize * 8.55;

      final coordText =
          String.fromCharCode('A'.codeUnitAt(0) + (reversed ? 7 - col : col));

      final textSpan = TextSpan(
        text: coordText,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y1));
      textPainter.paint(canvas, Offset(x, y2));
    }

    for (var row in range(8)) {
      final y = cellSize * (0.85 + row);
      final x1 = cellSize * 0.15;
      final x2 = cellSize * 8.65;

      final coordText =
          String.fromCharCode('8'.codeUnitAt(0) - (reversed ? 7 - row : row));

      final textSpan = TextSpan(
        text: coordText,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x1, y));
      textPainter.paint(canvas, Offset(x2, y));
    }

    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = blackTurn ? Colors.black : Colors.white;
    canvas.drawCircle(
        Offset(cellSize * 8.68, cellSize * 8.68), cellSize * 0.24, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (!(oldDelegate is ChessBoardCoordinatesPainter)) return false;
    final castedDelegate = oldDelegate as ChessBoardCoordinatesPainter;
    return reversed != castedDelegate.reversed ||
        size != castedDelegate.size ||
        blackTurn != castedDelegate.blackTurn;
  }
}
