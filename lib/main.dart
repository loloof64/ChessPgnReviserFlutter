// @dart=2.9
import 'dart:io';

import 'package:flutter/material.dart';
import 'pages/game_page.dart';
import 'package:provider/provider.dart';
import 'l10n/messages_handler.dart';

void main() {
  runApp(MyApp());
}

final MessagesHandler messagesHandler = MessagesHandler();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Pgn Reviser',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'FreeSerif',
      ),
      home: ChangeNotifierProvider(
        child: GamePage(),
        create: (context) {
          ///////////////////////////
          print(Platform.localeName.substring(0, 2));
          //////////////////////////////
          messagesHandler.setLocale(Platform.localeName.substring(0, 2));
          return messagesHandler;
        },
      ),
    );
  }
}
