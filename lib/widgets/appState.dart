import '../../modules/Communication.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  Communication _com;

  // Initializes the app state with an existing communication object
  AppState(this._com);

  // com object getter
  Communication get com => _com;

  // Replaces the communication object and notifies all listeners to rebuild
  void replaceCom(Communication newCom) {
    _com = newCom;
    notifyListeners(); // rebuilds all listeners
  }
}