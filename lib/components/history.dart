// @dart=2.9
import 'package:flutter/material.dart';

class HistoryWidget extends StatefulWidget {
  final double width;
  final double height;
  final List<HistoryItem> content;
  final bool reactivityEnabled;
  final String startPosition;

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
      @required this.reactivityEnabled,
      @required this.startPosition,
      this.handleHistoryPositionRequested});

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  int _selectedItemIndex = -1;

  Widget buildSingleItem(HistoryItem item, int index) {
    final baseWidget = Text(
      item.text,
      style: TextStyle(
        fontSize: widget.width * 0.06,
        fontFamily: 'FreeSerif',
      ),
    );

    return widget.reactivityEnabled
        ? GestureDetector(
            child: baseWidget,
            onTap: () {
              setState(() {
                _selectedItemIndex = index;
              });
              requestPositionBasedOnCurrentItemIndex();
            })
        : baseWidget;
  }

  void requestPositionBasedOnCurrentItemIndex() {
    if (_selectedItemIndex >= 0 && _selectedItemIndex < widget.content.length) {
      final item = widget.content[_selectedItemIndex];

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
    }
  }

  void requestStartPosition() {
    widget.handleHistoryPositionRequested(
      fen: widget.startPosition,
      lastMoveStartFile: null,
      lastMoveStartRank: null,
      lastMoveEndFile: null,
      lastMoveEndRank: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        HistoryNavigationWidget(
            enabled: widget.reactivityEnabled,
            height: viewport.height * 0.035,
            onGotoFirstItemRequested: () {
              setState(() {
                _selectedItemIndex = -1;
                requestStartPosition();
              });
            },
            onGotoPreviousItemRequested: () {
              setState(() {
                if (_selectedItemIndex > 1) {
                  do {
                    _selectedItemIndex--;
                  } while (_selectedItemIndex >= 0 &&
                      widget.content[_selectedItemIndex].fenAfterMove == null);
                  requestPositionBasedOnCurrentItemIndex();
                } else if (_selectedItemIndex == 1) {
                  _selectedItemIndex = -1;
                  requestStartPosition();
                }
              });
            },
            onGotoNextItemRequested: () {
              final noMove = widget.content.length < 2;
              if (noMove) return;
              if (_selectedItemIndex < widget.content.length - 1) {
                setState(() {
                  do {
                    _selectedItemIndex++;
                  } while (
                      widget.content[_selectedItemIndex].fenAfterMove == null);
                  requestPositionBasedOnCurrentItemIndex();
                });
              }
            },
            onGotoLastItemRequested: () {
              final noMove = widget.content.length < 2;
              if (noMove) return;
              setState(() {
                _selectedItemIndex = widget.content.length - 1;
                while (
                    widget.content[_selectedItemIndex].fenAfterMove == null) {
                  _selectedItemIndex--;
                }
                requestPositionBasedOnCurrentItemIndex();
              });
            }),
        HistoryMainZoneWidget(
          width: widget.width,
          height: widget.height,
          content: widget.content
              .asMap()
              .entries
              .map((entry) => buildSingleItem(entry.value, entry.key))
              .toList(),
        ),
      ],
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

  @override
  String toString() {
    return 'HistoryItem(text: $text, fenAfterMove: $fenAfterMove, lastMoveStartFile: $lastMoveStartFile, lastMoveStartRank: $lastMoveStartRank, lastMoveEndFile: $lastMoveEndFile, lastMoveEndRank: $lastMoveEndRank)';
  }
}

class HistoryMainZoneWidget extends StatelessWidget {
  final double width;
  final double height;
  final List<Widget> content;

  HistoryMainZoneWidget(
      {@required this.width, @required this.height, @required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color: Colors.grey[200],
      width: width,
      height: height,
      child: Wrap(
        children: content,
        spacing: width * 0.01,
      ),
    );
  }
}

class HistoryNavigationWidget extends StatelessWidget {
  final void Function() onGotoFirstItemRequested;
  final void Function() onGotoPreviousItemRequested;
  final void Function() onGotoNextItemRequested;
  final void Function() onGotoLastItemRequested;
  final double height;
  final bool enabled;

  HistoryNavigationWidget(
      {@required this.height,
      @required this.onGotoFirstItemRequested,
      @required this.onGotoPreviousItemRequested,
      @required this.onGotoNextItemRequested,
      @required this.onGotoLastItemRequested,
      @required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          HistoryNavigationButton(
              enabled: enabled,
              imageReference: 'images/first_item.png',
              onPressed: onGotoFirstItemRequested),
          HistoryNavigationButton(
              enabled: enabled,
              imageReference: 'images/previous_item.png',
              onPressed: onGotoPreviousItemRequested),
          HistoryNavigationButton(
              enabled: enabled,
              imageReference: 'images/next_item.png',
              onPressed: onGotoNextItemRequested),
          HistoryNavigationButton(
              enabled: enabled,
              imageReference: 'images/last_item.png',
              onPressed: onGotoLastItemRequested),
        ],
      ),
    );
  }
}

class HistoryNavigationButton extends StatelessWidget {
  final String imageReference;
  final void Function() onPressed;
  final bool enabled;

  HistoryNavigationButton({
    @required this.imageReference,
    @required this.onPressed,
    @required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      label: Text(''),
      icon: Image(
        fit: BoxFit.contain,
        image: AssetImage(imageReference),
      ),
      onPressed: enabled ? onPressed : null,
    );
  }
}
