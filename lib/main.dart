import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/memego.dart';
import 'widgets/appState.dart';

import 'dart:io';
import 'modules/keySwap.dart';
import 'modules/Communication.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final s = await Socket.connect("10.0.2.2", 4133);

  final Communication com = await Keyswap.swap(s);

  runApp( ChangeNotifierProvider(
      create: (_) => AppState(com),
      child: MemeGo(),
    ),);
}
