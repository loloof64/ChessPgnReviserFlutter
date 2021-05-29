// @dart=2.9
import 'package:chess_pgn_reviser/chessboard/chessboard_types.dart';
import 'package:chess_pgn_reviser/chessboard/chesssquare.dart';
import 'package:flutter/material.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

class ChessPiece extends StatelessWidget {
  final String type;
  final double size;
  final String cellName;
  final Function(String startCell) onStartDrag;

  ChessPiece(
      {@required this.type,
      @required this.size,
      @required this.cellName,
      this.onStartDrag});

  @override
  Widget build(BuildContext context) {
    final pieceWidget = _buildPiece();

    return Draggable<DragAndDropData>(
      data: DragAndDropData(cellName, type),
      child: pieceWidget,
      feedback: pieceWidget,
      childWhenDragging: ChessSquare(
        size: size,
      ),
      onDragStarted: () {
        if (onStartDrag != null) onStartDrag(cellName);
      },
    );
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
        return null;
    }
  }
}
