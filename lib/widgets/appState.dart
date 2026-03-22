import '../../modules/Communication.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  Communication _com;

  AppState(this._com);

  Communication get com => _com;

  void replaceCom(Communication newCom) {
    _com = newCom;
    notifyListeners(); // rebuilds all listeners
  }
}