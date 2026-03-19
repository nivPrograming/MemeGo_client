import 'package:client/models/data_base_types.dart';
import 'package:flutter/material.dart';
import '../screens/home/home.dart';
import '../screens/login/login.dart';
import '../Screens/verify_token/verify_token.dart';
import '../Screens/singup/signup.dart';
import '../Screens/auth/auth.dart';
import '../screens/catch/catch.dart';
import '../screens/storage/storage.dart';

import '../modules/Communication.dart';


class MemeGo extends StatelessWidget {
  final Communication com;
  const MemeGo({super.key, required this.com});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/verify_token",
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case "/home":
            return MaterialPageRoute(builder: (context) => HomePage(com: com));
          case "/login":
            return MaterialPageRoute(builder: (context) => LoginPage(com: com));
          case "/verify_token":
            return MaterialPageRoute(builder: (context) => VerifyToken(com: com));
          case "/signup":
            return MaterialPageRoute(builder: (context) => SignupPage(com: com));
          case "/auth":
            return MaterialPageRoute(builder: (context) => AuthPage(com: com));
          case "/storage":
            return MaterialPageRoute(builder: (context) => StoragePage(com: com));

            
          
          case "/catch":
            final extraData = settings.arguments as CreaturesInTheWild;
            return MaterialPageRoute(
              builder: (context) => CatchPage(com: com, creature: extraData),
            );

          default:
            return MaterialPageRoute(builder: (context) => SignupPage(com: com));
        }
      },
        
    );
  }
}