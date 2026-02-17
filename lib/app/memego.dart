import 'package:flutter/material.dart';
import '../screens/home/home.dart';
import '../screens/login/login.dart';

import '../modules/Communication.dart';


class MemeGo extends StatelessWidget {
  final Communication com;
  const MemeGo({super.key, required this.com});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/login",
      routes:{
         "/home": (context) => HomePage(com: com),
         "/login": (context) => LoginPage(com: com)

        },
        
    );
  }
}