import 'package:client/modules/Communication.dart';
import 'package:flutter/material.dart';
import 'signup_state.dart';

class SignupPage extends StatefulWidget {
  final Communication com;

  const SignupPage({
    super.key,
    required this.com,
  });

  @override
  State<SignupPage> createState() => SignupPageState();
}
