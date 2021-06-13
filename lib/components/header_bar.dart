// @dart=2.9
import 'package:flutter/material.dart';

class HeaderBar extends StatelessWidget {
  final double width;
  final double height;

  final void Function() startGame;
  final void Function() reverseBoard;
  final void Function() stopGame;

  HeaderBar({
    @required this.width,
    @required this.height,
    @required this.startGame,
    @required this.stopGame,
    @required this.reverseBoard,
  });

  @override
  Widget build(BuildContext context) {
    final commonHeight = height * 0.9;
    final commonPadding = 10.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: Colors.teal[200],
      ),
      margin: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          HeaderBarButton(
            imageReference: 'images/racing_flag.png',
            imagePadding: commonPadding,
            imageHeight: commonHeight,
            onPressed: startGame,
          ),
          HeaderBarButton(
            imageReference: 'images/stop.png',
            imagePadding: commonPadding,
            imageHeight: commonHeight,
            onPressed: stopGame,
          ),
          HeaderBarButton(
            imageReference: 'images/reverse_arrows.png',
            imagePadding: commonPadding,
            imageHeight: commonHeight,
            onPressed: reverseBoard,
          ),
        ],
      ),
    );
  }
}

class HeaderBarButton extends StatelessWidget {
  const HeaderBarButton({
    @required this.imagePadding,
    @required this.imageHeight,
    @required this.onPressed,
    @required this.imageReference,
  });

  final double imagePadding;
  final double imageHeight;
  final void Function() onPressed;
  final String imageReference;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: imagePadding),
      child: TextButton.icon(
        label: Text(''),
        icon: Image(
          image: AssetImage(imageReference),
          width: imageHeight,
          height: imageHeight,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
