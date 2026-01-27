import 'package:flutter/material.dart';
import '../screens/home/home.dart';


class MemeGo extends StatelessWidget {
  const MemeGo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/home",
      routes:{
         "/home": (context) => const HomePage()
        },
        
    );
  }
}