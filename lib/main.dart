import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/memego.dart';
import 'widgets/appState.dart';

import 'dart:io';
import 'modules/keySwap.dart';
import 'modules/Communication.dart';

void main() async{
  //initialises the connection and runs the fluute app
  WidgetsFlutterBinding.ensureInitialized();
  final Communication? com = await Communication.restoreCon();

  if (com != null){
    runApp( ChangeNotifierProvider(
        create: (_) => AppState(com),
        child: MemeGo(),
      ),);
  }
}
