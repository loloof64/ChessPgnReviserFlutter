// @dart=2.9
import 'package:flutter/material.dart';

class HistoryWidget extends StatefulWidget {
  final double width;
  final double height;
  final List<HistoryItem> content;

  HistoryWidget(
      {@required this.width, @required this.height, @required this.content});

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color: Colors.grey[200],
      width: widget.width,
      height: widget.height,
      child: Wrap(
        children: widget.content
            .map((word) => Text(
                  word.text,
                  style: TextStyle(
                    fontSize: widget.width * 0.06,
                    fontFamily: 'FreeSerif',
                  ),
                ))
            .toList(),
        spacing: widget.width * 0.01,
      ),
    );
  }
}

class HistoryItem {
  final String text;
  final String fenAfterMove;
  final int lastMoveStartFile;
  final int lastMoveStartRank;
  final int lastMoveEndFile;
  final int lastMoveEndRank;

  HistoryItem({
    @required this.text,
    this.fenAfterMove,
    this.lastMoveStartFile,
    this.lastMoveStartRank,
    this.lastMoveEndFile,
    this.lastMoveEndRank,
  });

  HistoryItem.moveNumber(int moveNumber, bool blackTurn)
      : text = '$moveNumber.${blackTurn ? '...' : ''}',
        fenAfterMove = null,
        lastMoveStartFile = null,
        lastMoveStartRank = null,
        lastMoveEndFile = null,
        lastMoveEndRank = null;
}
