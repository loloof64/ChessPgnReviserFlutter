// @dart=2.9
import 'package:chess_pgn_reviser/models/dark_mode_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppBarActions extends StatefulWidget {
  @override
  _AppBarActionsState createState() => _AppBarActionsState();
}

class _AppBarActionsState extends State<AppBarActions> {
  List<bool> _darkModeButtonsSelection = <bool>[true, false];

  List<Widget> buildAboutChildren() {
    List<String> inputs = <String>[
      'Laurent Bernabé',
      '2021',
      '',
      AppLocalizations.of(context).appDescription,
      '',
      AppLocalizations.of(context).creditsSection,
    ];
    List<Widget> results = inputs
        .map(
          (inputText) => Text(
            inputText,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        )
        .toList();
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Provider.of<DarkModeManager>(context).isActive;

    return Row(
      children: <Widget>[
        TextButton.icon(
          label: Text(''),
          icon: Image(
            image: AssetImage('images/info.png'),
            width: 40.0,
            height: 40.0,
          ),
          onPressed: () {
            showAboutDialog(
              context: context,
              applicationName: 'Chess Pgn reviser',
              applicationVersion: '1.0.0',
              children: buildAboutChildren(),
            );
          },
        ),
        ToggleButtons(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          isSelected: _darkModeButtonsSelection,
          onPressed: (int index) {
            setState(
              () {
                for (int buttonIndex = 0;
                    buttonIndex < _darkModeButtonsSelection.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    _darkModeButtonsSelection[buttonIndex] = true;
                  } else {
                    _darkModeButtonsSelection[buttonIndex] = false;
                  }
                }

                Provider.of<DarkModeManager>(context, listen: false)
                    .setActive(_darkModeButtonsSelection[1]);
              },
            );
          },
          children: <Widget>[
            TextButton.icon(
              onPressed: null,
              icon: Image(
                image: AssetImage('images/sun.png'),
                width: 40.0,
                height: 40.0,
              ),
              label: Text(''),
            ),
            TextButton.icon(
              onPressed: null,
              icon: Image(
                image: AssetImage('images/night.png'),
                width: 40.0,
                height: 40.0,
              ),
              label: Text(''),
            ),
          ],
          fillColor: isDarkMode ? Colors.blue : Colors.green,
        ),
        SizedBox(
          width: 50.0,
        )
      ],
    );
  }
}
