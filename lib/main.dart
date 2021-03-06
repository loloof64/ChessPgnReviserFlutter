import 'package:chess_pgn_reviser/models/dark_mode_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'pages/game_page.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';

final DarkModeManager darkModeManager = DarkModeManager();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DarkModeManager(),
      child: OKToast(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeManager>(context).isActive;

    return MaterialApp(
      title: 'Chess Pgn Reviser',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('fr', ''), // French, no country code
        const Locale('es', ''), // Spanish, no country code
      ],
      theme: isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.brown.shade200,
              textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: 'FreeSerif',
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.lightGreen,
              textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: 'FreeSerif',
                    bodyColor: Colors.black,
                    displayColor: Colors.black,
                  ),
            ),
      home: GamePage(),
    );
  }
}
