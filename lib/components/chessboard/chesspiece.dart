import 'chessboard_types.dart';
import 'chesssquare.dart';
import 'package:flutter/material.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

class ChessPiece extends StatelessWidget {
  final String type;
  final double size;
  final String cellName;
  final bool userCanMovePieces;
  final Function(String startCell)? onStartDrag;

  ChessPiece(
      {required this.type,
      required this.size,
      required this.cellName,
      this.userCanMovePieces = false,
      this.onStartDrag});

  @override
  Widget build(BuildContext context) {
    final pieceWidget = _buildPiece();

    return (userCanMovePieces == true)
        ? Draggable<DragAndDropData>(
            data: DragAndDropData(cellName, type),
            child: pieceWidget,
            feedback: pieceWidget,
            childWhenDragging: ChessSquare(
              size: size,
              squareName: cellName,
            ),
            onDragStarted: () {
              onStartDrag?.call(cellName);
            },
          )
        : pieceWidget;
  }

  Widget _buildPiece() {
    switch (type) {
      case 'R':
        return WhiteRook(size: size);
      case 'N':
        return WhiteKnight(size: size);
      case 'B':
        return WhiteBishop(size: size);
      case 'K':
        return WhiteKing(size: size);
      case 'Q':
        return WhiteQueen(size: size);
      case 'P':
        return WhitePawn(size: size);
      case 'r':
        return BlackRook(size: size);
      case 'n':
        return BlackKnight(size: size);
      case 'b':
        return BlackBishop(size: size);
      case 'k':
        return BlackKing(size: size);
      case 'q':
        return BlackQueen(size: size);
      case 'p':
        return BlackPawn(size: size);
      default:
        return Container();
    }
  }
}
