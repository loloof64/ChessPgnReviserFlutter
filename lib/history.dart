import 'package:flutter/material.dart';

class HistoryWidget extends StatefulWidget {
  final double width;
  final double height;

  const HistoryWidget(this.width, this.height);

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  @override
  Widget build(BuildContext context) {
    final content = [
      "Simple",
      "text",
      "test",
      "Hello",
      "World",
      "!",
      "Simple",
      "text",
      "test",
      "Hello",
      "World",
      "!",
      "Simple",
      "text",
      "test",
      "Hello",
      "World",
      "!",
      "Simple",
      "text",
      "test",
      "Hello",
      "World",
      "!",
    ].map((word) => Text(word)).toList();

    return Container(
      color: Colors.grey[200],
      width: widget.width,
      height: widget.height,
      child: Wrap(
        children: content,
        spacing: widget.width * 0.01,
      ),
    );
  }
}
