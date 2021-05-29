// @dart=2.9

import 'package:flutter/material.dart';
import 'package:chess_pgn_reviser/chesspiece.dart';
import 'package:chess_pgn_reviser/chessboard_types.dart';

class ChessSquare extends StatelessWidget {
  final double size;
  final Color color;
  final String pieceType;
  final String squareName;
  final void Function(String startCell, String endCell) onDrop;

  ChessSquare({
    @required this.size,
    this.color,
    this.pieceType,
    this.squareName,
    this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragAndDropData>(
      onWillAccept: (data) {
        return data.startCellName != squareName;
      },
      onAccept: (data) {
        if (onDrop != null) {
          onDrop(data.startCellName, squareName);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: size,
          height: size,
          color: color,
          child: pieceType != null
              ? ChessPiece(
                  size: size,
                  type: pieceType,
                  cellName: squareName,
                )
              : Container(width: 0.0, height: 0.0),
        );
      },
    );
  }
}
