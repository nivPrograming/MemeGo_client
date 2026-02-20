import 'package:flutter/material.dart';
import 'verify_token_state.dart';
import '../../modules/Communication.dart';

class VerifyToken extends StatefulWidget {
 final Communication com;

  const VerifyToken({
    super.key,
    required this.com,
  });

  @override
  State<VerifyToken> createState() => VerifyTokenState();
}

