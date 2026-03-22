import 'package:client/models/data_base_types.dart';
import 'package:flutter/material.dart';
import '../screens/home/home.dart';
import '../screens/login/login.dart';
import '../Screens/verify_token/verify_token.dart';
import '../Screens/singup/signup.dart';
import '../Screens/auth/auth.dart';
import '../screens/catch/catch.dart';
import '../screens/storage/storage.dart';
import '../screens/reconnect/reconnect.dart';



class MemeGo extends StatelessWidget {
  const MemeGo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/verify_token",
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case "/home":
            return MaterialPageRoute(builder: (context) => HomePage());
          case "/login":
            return MaterialPageRoute(builder: (context) => LoginPage());
          case "/verify_token":
            return MaterialPageRoute(builder: (context) => VerifyToken());
          case "/signup":
            return MaterialPageRoute(builder: (context) => SignupPage());
          case "/auth":
            return MaterialPageRoute(builder: (context) => AuthPage());
          case "/storage":
            return MaterialPageRoute(builder: (context) => StoragePage());
          case "/reconnect":
            return MaterialPageRoute(builder: (context) => ReconnectPage());

            
          
          case "/catch":
            final extraData = settings.arguments as CreaturesInTheWild;
            return MaterialPageRoute(
              builder: (context) => CatchPage(creature: extraData),
            );

          default:
            return MaterialPageRoute(builder: (context) => SignupPage());
        }
      },
        
    );
  }
}