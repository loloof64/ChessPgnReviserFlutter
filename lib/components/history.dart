// @dart=2.9
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dark_mode_manager.dart';

class HistoryWidget extends StatefulWidget {
  final double width;
  final double height;
  final List<HistoryItem> content;
  final bool reactivityEnabled;
  final String startPosition;
  final int selectedItemIndex;

  final void Function(
      {String fen,
      int lastMoveStartFile,
      int lastMoveStartRank,
      int lastMoveEndFile,
      int lastMoveEndRank}) handleHistoryPositionRequested;

  final void Function(int index) handleHistoryItemRequested;
  final void Function() handleHistoryGotoFirstItemRequested;
  final void Function() handleHistoryGotoPreviousItemRequested;
  final void Function() handleHistoryGotoNextItemRequested;
  final void Function() handleHistoryGotoLastItemRequested;

  HistoryWidget(
      {@required this.width,
      @required this.height,
      @required this.content,
      @required this.reactivityEnabled,
      @required this.startPosition,
      @required this.selectedItemIndex,
      @required this.handleHistoryItemRequested,
      this.handleHistoryPositionRequested,
      this.handleHistoryGotoFirstItemRequested,
      this.handleHistoryGotoPreviousItemRequested,
      this.handleHistoryGotoNextItemRequested,
      this.handleHistoryGotoLastItemRequested});

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  Widget buildSingleItem(BuildContext context, HistoryItem item, int index) {
    final isDarkMode = Provider.of<DarkModeManager>(context).isActive;

    final baseWidget = Text(
      item.text,
      style: TextStyle(
          fontSize: widget.width * 0.06,
          color: isDarkMode ? Colors.white : Colors.black),
    );

    if (widget.reactivityEnabled && item.fenAfterMove != null) {
      final result = GestureDetector(
          child: baseWidget,
          onTap: () {
            setState(() {
              widget.handleHistoryItemRequested(index);
            });
          });
      if (index == widget.selectedItemIndex) {
        return Container(
          color: Colors.yellow[isDarkMode ? 800 : 200],
          child: result,
        );
      } else
        return result;
    } else {
      return baseWidget;
    }
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
            onGotoFirstItemRequested:
                widget.handleHistoryGotoFirstItemRequested,
            onGotoPreviousItemRequested:
                widget.handleHistoryGotoPreviousItemRequested,
            onGotoNextItemRequested: widget.handleHistoryGotoNextItemRequested,
            onGotoLastItemRequested: widget.handleHistoryGotoLastItemRequested),
        HistoryMainZoneWidget(
          width: widget.width,
          height: widget.height,
          content: widget.content
              .asMap()
              .entries
              .map((entry) => buildSingleItem(context, entry.value, entry.key))
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
    final isDarkMode = Provider.of<DarkModeManager>(context).isActive;

    return Container(
      padding: EdgeInsets.all(10.0),
      color: Colors.grey[isDarkMode ? 800 : 200],
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
    final isDarkMode = Provider.of<DarkModeManager>(context).isActive;

    return Container(
      child: TextButton.icon(
        label: Text(''),
        icon: Image(
          fit: BoxFit.contain,
          image: AssetImage(imageReference),
        ),
        onPressed: enabled ? onPressed : null,
      ),
      color: isDarkMode ? Colors.white38 : Colors.transparent,
    );
  }
}
