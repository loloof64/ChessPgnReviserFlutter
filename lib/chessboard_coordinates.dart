// @dart=2.9
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';

final zeroToSeven = List.generate(8, (index) => index);

class ChessBoardCoordinates extends StatelessWidget {
  final double size;
  final bool reversed;
  final bool blackTurn;

  final bool lastMoveVisible;
  final int lastMoveStartFile;
  final int lastMoveStartRank;
  final int lastMoveEndFile;
  final int lastMoveEndRank;

  ChessBoardCoordinates(
      {@required this.size,
      this.reversed,
      this.blackTurn,
      this.lastMoveVisible,
      this.lastMoveStartFile,
      this.lastMoveStartRank,
      this.lastMoveEndFile,
      this.lastMoveEndRank});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: ChessBoardCoordinatesPainter(
          reversed,
          size,
          blackTurn,
          lastMoveVisible,
          lastMoveStartFile,
          lastMoveStartRank,
          lastMoveEndFile,
          lastMoveEndRank),
    );
  }
}

class ChessBoardCoordinatesPainter extends CustomPainter {
  final bool reversed;
  final double size;
  final bool blackTurn;

  final bool lastMoveVisible;
  final int lastMoveStartFile;
  final int lastMoveStartRank;
  final int lastMoveEndFile;
  final int lastMoveEndRank;

  ChessBoardCoordinatesPainter(
      this.reversed,
      this.size,
      this.blackTurn,
      this.lastMoveVisible,
      this.lastMoveStartFile,
      this.lastMoveStartRank,
      this.lastMoveEndFile,
      this.lastMoveEndRank);

  double cellSizeFrom(Size size) {
    final minSize = size.width < size.height ? size.width : size.height;
    return minSize * 0.112;
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintBackground(canvas, size);
    paintCoordinates(canvas, size);
    paintPlayerTurn(canvas, size);
    paintLastMoveArrow(canvas, size);
  }

  void paintBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.green[300];
    final rect = Offset.zero & size;
    canvas.drawRect(rect, backgroundPaint);
  }

  void paintCoordinates(Canvas canvas, Size size) {
    final cellSize = cellSizeFrom(size);

    final textStyle = TextStyle(
      color: Colors.yellowAccent.shade700,
      fontSize: cellSize * 0.3,
    );

    zeroToSeven.forEach((col) {
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
    });

    zeroToSeven.forEach((row) {
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
    });
  }

  void paintPlayerTurn(Canvas canvas, Size size) {
    final cellSize = cellSizeFrom(size);

    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = blackTurn ? Colors.black : Colors.white;
    canvas.drawCircle(
        Offset(cellSize * 8.68, cellSize * 8.68), cellSize * 0.24, circlePaint);
  }

  void paintLastMoveArrow(Canvas canvas, Size size) {
    if (lastMoveVisible == null || !lastMoveVisible) return;
    final cellSize = cellSizeFrom(size);

    final paint = Paint()
      ..color = Colors.blue[900]
      ..strokeWidth = cellSize * 0.1;

    final realOriginCol = reversed ? 7 - lastMoveStartFile : lastMoveStartFile;
    final realOriginRow = reversed ? lastMoveStartRank : 7 - lastMoveStartRank;
    final realDestCol = reversed ? 7 - lastMoveEndFile : lastMoveEndFile;
    final realDestRow = reversed ? lastMoveEndRank : 7 - lastMoveEndRank;
    final baseStartX = cellSize * (1.0 + realOriginCol);
    final baseStartY = cellSize * (1.0 + realOriginRow);
    final baseStopX = cellSize * (1.0 + realDestCol);
    final baseStopY = cellSize * (1.0 + realDestRow);
    final deltaX = baseStopX - baseStartX;
    final deltaY = baseStopY - baseStartY;
    final baseLineAngleRad = atan2(deltaY, deltaX);
    final edge1AngleRad = baseLineAngleRad + 2.618;
    final edge2AngleRad = baseLineAngleRad + 3.665;
    final edge1StartX = baseStopX;
    final edge1StartY = baseStopY;
    final edge1StopX = baseStopX + cellSize * cos(edge1AngleRad) * 0.6;
    final edge1StopY = baseStopY + cellSize * sin(edge1AngleRad) * 0.6;
    final edge2StartX = baseStopX;
    final edge2StartY = baseStopY;
    final edge2StopX = baseStopX + cellSize * cos(edge2AngleRad) * 0.6;
    final edge2StopY = baseStopY + cellSize * sin(edge2AngleRad) * 0.6;
    canvas.drawLine(
        Offset(baseStartX, baseStartY), Offset(baseStopX, baseStopY), paint);
    canvas.drawLine(Offset(edge1StartX, edge1StartY),
        Offset(edge1StopX, edge1StopY), paint);
    canvas.drawLine(Offset(edge2StartX, edge2StartY),
        Offset(edge2StopX, edge2StopY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (!(oldDelegate is ChessBoardCoordinatesPainter)) return false;
    final castedDelegate = oldDelegate as ChessBoardCoordinatesPainter;
    return reversed != castedDelegate.reversed ||
        size != castedDelegate.size ||
        blackTurn != castedDelegate.blackTurn ||
        lastMoveVisible != castedDelegate.lastMoveVisible ||
        lastMoveStartFile != castedDelegate.lastMoveStartFile ||
        lastMoveStartRank != castedDelegate.lastMoveStartRank ||
        lastMoveEndFile != castedDelegate.lastMoveEndFile ||
        lastMoveEndRank != castedDelegate.lastMoveEndRank;
  }
}
