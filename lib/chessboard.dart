// @dart=2.9

import 'package:chess_pgn_reviser/chesssquare.dart';
import 'package:flutter/material.dart';
import 'package:chess_pgn_reviser/chessboard_types.dart';

final zeroToSeven = List.generate(8, (index) => index);

class ChessBoard extends StatefulWidget {
  final String fen;
  final double size;
  final bool blackAtBottom;
  final void Function(String startCell, String endCell) onMove;
  final void Function() onLeave;

  ChessBoard({
    @required this.fen,
    @required this.size,
    this.blackAtBottom,
    this.onMove,
    this.onLeave,
  });

  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  Cell _hoveredCell;
  Cell _startCell;

  @override
  Widget build(BuildContext context) {
    final cellSize = widget.size / 8.0;

    final whiteCellColor = Color(0x93ffce9e);
    final blackCellColor = Color(0x93d18b47);

    final startCellColor = Color(0x93d63b60);
    final targetCellColor = Color(0x9370d123);
    final dndCrossCellColor = Color(0x93b22ee6);

    var pieces = getPieces();

    return Container(
      width: widget.size,
      height: widget.size,
      child: Column(
        children: zeroToSeven.map((row) {
          final rank = widget.blackAtBottom ? row : 7 - row;
          return Row(
              children: zeroToSeven.map((col) {
            final file = widget.blackAtBottom ? 7 - col : col;
            final isWhiteCell = (col + row) % 2 != 0;
            final isDndCrossCell = (_hoveredCell != null) &&
                (file == _hoveredCell.file || rank == _hoveredCell.rank);
            final isTargetCell = (_hoveredCell != null) &&
                (file == _hoveredCell.file && rank == _hoveredCell.rank);
            final isStartCell = (_startCell != null) &&
                (file == _startCell.file && rank == _startCell.rank);
            var color = isWhiteCell ? whiteCellColor : blackCellColor;
            if (isStartCell) color = startCellColor;
            if (isDndCrossCell) color = dndCrossCellColor;
            if (isTargetCell) color = targetCellColor;
            final squareName =
                "${String.fromCharCode('a'.codeUnitAt(0) + file)}${String.fromCharCode('1'.codeUnitAt(0) + rank)}";
            return ChessSquare(
              size: cellSize,
              color: color,
              pieceType: pieces[rank][file],
              squareName: squareName,
              onDrop: (startCell, endCell) {
                setState(() {
                  _hoveredCell = null;
                  _startCell = null;
                });
                if (widget.onMove != null) {
                  widget.onMove(startCell, endCell);
                  setState(() {
                    pieces = getPieces();
                  });
                }
              },
              onHover: (squareName) {
                setState(() {
                  _hoveredCell = Cell.fromAlgebraic(squareName);
                });
              },
              onLeave: () {
                setState(() {
                  _hoveredCell = null;
                });
              },
              onStartDrag: (squareName) {
                setState(() {
                  _startCell = Cell.fromAlgebraic(squareName);
                });
              },
            );
          }).toList());
        }).toList(),
      ),
    );
  }

  List<List<String>> getPieces() {
    final valuesArray =
        widget.fen.split(" ")[0].split("/").map((line) => line.split(""));
    var results = <List<String>>[];
    valuesArray.forEach((line) {
      var lineResults = <String>[];
      line.forEach((element) {
        try {
          var holes = int.parse(element);
          for (var i = 0; i < holes; i++) lineResults.add(null);
        } catch (e) {
          lineResults.add(element);
        }
      });
      results.add(lineResults);
    });
    return List.from(results.reversed);
  }
}
