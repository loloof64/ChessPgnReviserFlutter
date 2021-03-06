import 'chesssquare.dart';
import 'package:flutter/material.dart';
import 'chessboard_types.dart';

final zeroToSeven = List.generate(8, (index) => index);

class ChessBoardMainZone extends StatefulWidget {
  final String fen;
  final double size;
  final bool blackAtBottom;
  final bool userCanMovePieces;
  final void Function(String startCell, String endCell)? onMove;

  ChessBoardMainZone({
    required this.fen,
    required this.size,
    required this.onMove,
    this.blackAtBottom = false,
    this.userCanMovePieces = true,
  });

  _ChessBoardMainZoneState createState() => _ChessBoardMainZoneState();
}

class _ChessBoardMainZoneState extends State<ChessBoardMainZone> {
  Cell? _hoveredCell;
  Cell? _startCell;
  Cell? _cachedStartCell;

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
            final isWhiteCell = (col + row) % 2 == 0;
            final isDndCrossCell = (_hoveredCell != null) &&
                (file == (_hoveredCell?.file ?? 0) ||
                    rank == (_hoveredCell?.rank ?? 0));
            final isTargetCell = (_hoveredCell != null) &&
                (file == (_hoveredCell?.file) && rank == _hoveredCell?.rank);
            final isStartCell = (_startCell != null) &&
                (file == _startCell!.file && rank == _startCell!.rank);
            var color = isWhiteCell ? whiteCellColor : blackCellColor;
            if (isDndCrossCell) color = dndCrossCellColor;
            if (isStartCell) color = startCellColor;
            if (isTargetCell) color = targetCellColor;

            final squareName =
                "${String.fromCharCode('a'.codeUnitAt(0) + file)}${String.fromCharCode('1'.codeUnitAt(0) + rank)}";
            return ChessSquare(
              size: cellSize,
              color: color,
              pieceType: pieces[rank][file],
              squareName: squareName,
              userCanMovePieces: widget.userCanMovePieces,
              onDrop: (startCell, endCell) {
                if (!widget.userCanMovePieces) return;
                setState(() {
                  _hoveredCell = null;
                  _startCell = null;
                });
                widget.onMove?.call(startCell, endCell);
                setState(() {
                  pieces = getPieces();
                });
              },
              onHover: (squareName) {
                if (!widget.userCanMovePieces) return;
                setState(() {
                  _hoveredCell = Cell.fromAlgebraic(squareName);
                  if (_cachedStartCell != null) _startCell = _cachedStartCell;
                });
              },
              onStartDrag: (squareName) {
                if (!widget.userCanMovePieces) return;
                setState(() {
                  final temp = Cell.fromAlgebraic(squareName);
                  _startCell = temp;
                  _cachedStartCell = temp;
                });
              },
              onLeave: () {
                setState(() {
                  _hoveredCell = null;
                  _startCell = null;
                });
              },
            );
          }).toList());
        }).toList(),
      ),
    );
  }

  List<List<String?>> getPieces() {
    final valuesArray =
        widget.fen.split(" ")[0].split("/").map((line) => line.split(""));
    var results = <List<String?>>[];
    valuesArray.forEach((line) {
      var lineResults = <String?>[];
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
