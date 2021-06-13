// @dart=2.9
import 'package:flutter/material.dart';

class HistoryWidget extends StatefulWidget {
  final double width;
  final double height;
  final List<HistoryItem> content;
  final bool onTouchActivated;
  final void Function(
      {String fen,
      int lastMoveStartFile,
      int lastMoveStartRank,
      int lastMoveEndFile,
      int lastMoveEndRank}) handleHistoryPositionRequested;

  HistoryWidget(
      {@required this.width,
      @required this.height,
      @required this.content,
      @required this.onTouchActivated,
      this.handleHistoryPositionRequested});

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  Widget buildSingleItem(HistoryItem item) {
    final baseWidget = Text(
      item.text,
      style: TextStyle(
        fontSize: widget.width * 0.06,
        fontFamily: 'FreeSerif',
      ),
    );

    return widget.onTouchActivated
        ? GestureDetector(
            child: baseWidget,
            onTap: () {
              if (item.fenAfterMove != null &&
                  widget.handleHistoryPositionRequested != null) {
                widget.handleHistoryPositionRequested(
                  fen: item.fenAfterMove,
                  lastMoveStartFile: item.lastMoveStartFile,
                  lastMoveStartRank: item.lastMoveStartRank,
                  lastMoveEndFile: item.lastMoveEndFile,
                  lastMoveEndRank: item.lastMoveEndRank,
                );
              }
            })
        : baseWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color: Colors.grey[200],
      width: widget.width,
      height: widget.height,
      child: Wrap(
        children: widget.content.map(buildSingleItem).toList(),
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
