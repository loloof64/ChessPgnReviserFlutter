import 'package:flutter/material.dart';

class HistoryWidget extends StatefulWidget {
  final double width;
  final double height;
  final List<String> content;

  HistoryWidget(
      {required this.width, required this.height, required this.content});

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
                  word,
                  style: TextStyle(fontSize: widget.width * 0.06),
                ))
            .toList(),
        spacing: widget.width * 0.01,
      ),
    );
  }
}
