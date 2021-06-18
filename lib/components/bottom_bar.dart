// @dart=2.9

import 'package:chess_pgn_reviser/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/messages_handler.dart';

class BottomBar extends StatelessWidget {
  final bool gameInProgress;
  final PlayerMode whiteMode;
  final PlayerMode blackMode;

  BottomBar({
    @required this.gameInProgress,
    @required this.whiteMode,
    @required this.blackMode,
  });

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
          whiteModeString =
              ' ${Provider.of<MessagesHandler>(context, listen: false).messages.gameModePlayerGuessMove}';
          whiteIcon = FontAwesomeIcons.questionCircle;
          break;
        case PlayerMode.ReadMoveByUserChoice:
          whiteModeString =
              ' ${Provider.of<MessagesHandler>(context, listen: false).messages.gameModeUserChooseMove}';
          whiteIcon = FontAwesomeIcons.codeBranch;
          break;
        case PlayerMode.ReadMoveRandomly:
          whiteModeString =
              ' ${Provider.of<MessagesHandler>(context, listen: false).messages.gameModeComputerPlaysRandomly}';
          whiteIcon = FontAwesomeIcons.dice;
          break;
        default:
          throw 'Unrecognized mode $whiteMode';
      }

      switch (blackMode) {
        case PlayerMode.GuessMove:
          blackModeString =
              ' ${Provider.of<MessagesHandler>(context, listen: false).messages.gameModePlayerGuessMove}';
          blackIcon = FontAwesomeIcons.questionCircle;
          break;
        case PlayerMode.ReadMoveByUserChoice:
          blackModeString =
              ' ${Provider.of<MessagesHandler>(context, listen: false).messages.gameModeUserChooseMove}';
          blackIcon = FontAwesomeIcons.codeBranch;
          break;
        case PlayerMode.ReadMoveRandomly:
          blackModeString =
              ' ${Provider.of<MessagesHandler>(context, listen: false).messages.gameModeComputerPlaysRandomly}';
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
                '${Provider.of<MessagesHandler>(context, listen: false).messages.whiteMode} : ',
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
                '${Provider.of<MessagesHandler>(context, listen: false).messages.blackMode} : ',
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
        Provider.of<MessagesHandler>(context, listen: false)
            .messages
            .gameNotInProgress,
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
