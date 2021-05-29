// @dart=2.9

import 'package:chess_pgn_reviser/chesssquare.dart';
import 'package:flutter/material.dart';

final zeroToSeven = List.generate(8, (index) => index);

class ChessBoard extends StatelessWidget {
  final String fen;
  final double size;
  final bool blackAtBottom;
  final void Function(String startCell, String endCell) onMove;

  ChessBoard(
      {@required this.fen,
      @required this.size,
      this.blackAtBottom,
      this.onMove});

  @override
  Widget build(BuildContext context) {
    final cellSize = size / 8.0;

    final whiteCellColor = Color(0xffffce9e);
    final blackCellColor = Color(0xffd18b47);

    final pieces = getPieces();

    return Container(
      width: size,
      height: size,
      child: Column(
        children: zeroToSeven.map((row) {
          final rank = blackAtBottom ? row : 7 - row;
          return Row(
              children: zeroToSeven.map((col) {
            final file = blackAtBottom ? 7 - col : col;
            final isWhiteCell = (col + row) % 2 != 0;
            final color = isWhiteCell ? whiteCellColor : blackCellColor;
            final squareName =
                "${String.fromCharCode('a'.codeUnitAt(0) + file)}${String.fromCharCode('1'.codeUnitAt(0) + rank)}";
            return ChessSquare(
              size: cellSize,
              color: color,
              pieceType: pieces[rank][file],
              squareName: squareName,
              onDrop: onMove,
            );
          }).toList());
        }).toList(),
      ),
    );
  }

  List<List<String>> getPieces() {
    final valuesArray =
        fen.split(" ")[0].split("/").map((line) => line.split(""));
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
