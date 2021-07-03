import 'package:chess_pgn_reviser/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomBar extends StatelessWidget {
  final bool gameInProgress;
  final PlayerMode whiteMode;
  final PlayerMode blackMode;

  BottomBar({
    required this.gameInProgress,
    required this.whiteMode,
    required this.blackMode,
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
              ' ${AppLocalizations.of(context)?.gameModePlayerGuessMove}';
          whiteIcon = FontAwesomeIcons.questionCircle;
          break;
        case PlayerMode.ReadMoveByUserChoice:
          whiteModeString =
              ' ${AppLocalizations.of(context)?.gameModeUserChooseMove}';
          whiteIcon = FontAwesomeIcons.codeBranch;
          break;
        case PlayerMode.ReadMoveRandomly:
          whiteModeString =
              ' ${AppLocalizations.of(context)?.gameModeComputerPlaysRandomly}';
          whiteIcon = FontAwesomeIcons.dice;
          break;
        default:
          throw 'Unrecognized mode $whiteMode';
      }

      switch (blackMode) {
        case PlayerMode.GuessMove:
          blackModeString =
              ' ${AppLocalizations.of(context)?.gameModePlayerGuessMove}';
          blackIcon = FontAwesomeIcons.questionCircle;
          break;
        case PlayerMode.ReadMoveByUserChoice:
          blackModeString =
              ' ${AppLocalizations.of(context)?.gameModeUserChooseMove}';
          blackIcon = FontAwesomeIcons.codeBranch;
          break;
        case PlayerMode.ReadMoveRandomly:
          blackModeString =
              ' ${AppLocalizations.of(context)?.gameModeComputerPlaysRandomly}';
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
                '${AppLocalizations.of(context)?.whiteMode} : ',
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
                '${AppLocalizations.of(context)?.blackMode} : ',
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
        AppLocalizations.of(context)?.gameNotInProgress ?? errorString,
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
