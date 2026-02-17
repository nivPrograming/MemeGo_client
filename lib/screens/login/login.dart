import 'package:client/modules/Communication.dart';
import 'package:flutter/material.dart';
import 'loginstate.dart';


class LoginPage extends StatefulWidget {

  final Communication com;

  const LoginPage({
    super.key,
    required this.com,
  });


  @override
  State<StatefulWidget> createState() => LoginState();
  
}