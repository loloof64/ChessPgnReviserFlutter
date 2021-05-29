// @dart=2.9
import 'dart:math';
import 'package:flutter/material.dart';

class ChessBoardLastMoveArrow extends StatelessWidget {
  final double size;
  final bool reversed;
  final bool visible;
  final int startFile;
  final int startRank;
  final int endFile;
  final int endRank;

  ChessBoardLastMoveArrow(
      {@required this.size,
      this.reversed,
      this.visible,
      this.startFile,
      this.startRank,
      this.endFile,
      this.endRank});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: ChessBoardLastMoveArrowPainter(
        size,
        reversed,
        startFile,
        startRank,
        endFile,
        endRank,
      ),
    );
  }
}

class ChessBoardLastMoveArrowPainter extends CustomPainter {
  final double size;
  final bool reversed;
  final int startFile;
  final int startRank;
  final int endFile;
  final int endRank;

  ChessBoardLastMoveArrowPainter(this.size, this.reversed, this.startFile,
      this.startRank, this.endFile, this.endRank);

  @override
  void paint(Canvas canvas, Size size) {
    final minSize = size.width < size.height ? size.width : size.height;
    final cellSize = minSize * 0.11525;

    final paint = Paint()
      ..color = Colors.blueAccent.shade400
      ..strokeWidth = cellSize * 0.1;

    final realOriginCol = reversed ? 7 - startFile : startFile;
    final realOriginRow = reversed ? startRank : 7 - startRank;
    final realDestCol = reversed ? 7 - endFile : endFile;
    final realDestRow = reversed ? endRank : 7 - endRank;
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
    if (!(oldDelegate is ChessBoardLastMoveArrowPainter)) return false;
    final castedDelegate = oldDelegate as ChessBoardLastMoveArrowPainter;
    return size != castedDelegate.size ||
        reversed != castedDelegate.reversed ||
        startFile != castedDelegate.startFile ||
        startRank != castedDelegate.startRank ||
        endFile != castedDelegate.endFile ||
        endRank != castedDelegate.endRank;
  }
}
