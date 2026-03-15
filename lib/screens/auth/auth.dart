import 'package:client/modules/Communication.dart';
import 'package:flutter/material.dart';
import 'auth_state.dart';

class AuthPage extends StatefulWidget {
  final Communication com;

  const AuthPage({
    super.key,
    required this.com,
  });

  @override
  State<AuthPage> createState() => AuthState();
}
