import 'package:flutter/material.dart';
import 'app/memego.dart';

import 'dart:io';
import 'modules/keySwap.dart';
import 'modules/Communication.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final s = await Socket.connect("127.0.0.1", 4133);

  final Communication com = await Keyswap.swap(s);

  runApp(MemeGo(com: com));
}
