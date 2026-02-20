import 'package:flutter/material.dart';
import '../screens/home/home.dart';
import '../screens/login/login.dart';
import '../Screens/verify_token/verify_token.dart';
import '../Screens/singup/signup.dart';

import '../modules/Communication.dart';


class MemeGo extends StatelessWidget {
  final Communication com;
  const MemeGo({super.key, required this.com});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/signup",
      routes:{
         "/home": (context) => HomePage(com: com),
         "/login": (context) => LoginPage(com: com),
         "/verify_token": (context) => VerifyToken(com: com),
         "/signup": (context) => SignupPage(com: com)
        },
        
    );
  }
}