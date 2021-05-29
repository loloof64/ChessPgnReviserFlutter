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
  final void Function(String hoveredCell) onHover;
  final void Function() onLeave;
  final Function(String startCell) onStartDrag;

  ChessSquare({
    @required this.size,
    this.color,
    this.pieceType,
    this.squareName,
    this.onDrop,
    this.onHover,
    this.onLeave,
    this.onStartDrag,
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
      onMove: (data) {
        if (onHover != null) {
          onHover(squareName);
        }
      },
      onLeave: (target) {
        if (onLeave != null) onLeave();
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
                  onStartDrag: onStartDrag,
                )
              : Container(width: 0.0, height: 0.0),
        );
      },
    );
  }
}
