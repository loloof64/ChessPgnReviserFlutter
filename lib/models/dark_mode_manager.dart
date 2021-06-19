import 'package:flutter/cupertino.dart';

class DarkModeManager extends ChangeNotifier {
  bool _active = false;

  void setActive(bool newValue) {
    _active = newValue;
    notifyListeners();
  }

  bool get isActive => _active;
}
