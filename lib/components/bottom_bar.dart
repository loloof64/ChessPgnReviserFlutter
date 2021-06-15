// @dart=2.9

import 'package:chess_pgn_reviser/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomBar extends StatelessWidget {
  final bool gameInProgress;
  final PlayerMode whiteMode;
  final PlayerMode blackMode;

  BottomBar(
      {@required this.gameInProgress,
      @required this.whiteMode,
      @required this.blackMode});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 18.0);
    final iconsSize = 18.0;

    Widget mainChild;
    if (gameInProgress) {
      String whiteModeString;
      String blackModeString;

      IconData whiteIcon;
      IconData blackIcon;

      switch (whiteMode) {
        case PlayerMode.GuessMove:
          whiteModeString = ' Computer lets user guess move';
          whiteIcon = FontAwesomeIcons.questionCircle;
          break;
        case PlayerMode.ReadMoveByUserChoice:
          whiteModeString = ' Computer plays moves by user choice';
          whiteIcon = FontAwesomeIcons.codeBranch;
          break;
        case PlayerMode.ReadMoveRandomly:
          whiteModeString = ' Computer plays moves randomly';
          whiteIcon = FontAwesomeIcons.dice;
          break;
        default:
          throw 'Unrecognized mode $whiteMode';
      }

      switch (blackMode) {
        case PlayerMode.GuessMove:
          blackModeString = ' Computer lets user guess move';
          blackIcon = FontAwesomeIcons.questionCircle;
          break;
        case PlayerMode.ReadMoveByUserChoice:
          blackModeString = ' Computer plays moves by user choice';
          blackIcon = FontAwesomeIcons.codeBranch;
          break;
        case PlayerMode.ReadMoveRandomly:
          blackModeString = ' Computer plays moves randomly';
          blackIcon = FontAwesomeIcons.dice;
          break;
        default:
          throw 'Unrecognized mode $blackMode';
      }

      mainChild = Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'White mode : ',
                style: textStyle,
              ),
              FaIcon(
                whiteIcon,
                size: iconsSize,
              ),
              Text(
                whiteModeString,
                style: textStyle,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Black mode : ',
                style: textStyle,
              ),
              FaIcon(
                blackIcon,
                size: iconsSize,
              ),
              Text(
                blackModeString,
                style: textStyle,
              )
            ],
          )
        ],
      );
    } else {
      mainChild = Text(
        'Game not in progress.',
        style: textStyle,
      );
    }

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: mainChild,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: Colors.grey[400],
      ),
    );
  }
}
