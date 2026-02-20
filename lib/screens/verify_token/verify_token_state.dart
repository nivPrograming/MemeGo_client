
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'verify_token.dart';
import '../../modules/Communication.dart';
import '../../models/Message.dart';
import '../../modules/jwt_storage.dart';

class VerifyTokenState extends State<VerifyToken> {

  @override
  void initState(){
    super.initState();

    _verifyToken();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Future<void> _verifyToken() async{
    String? jwtToken = await JwtStorage().read();

    if (jwtToken == null){
      if (mounted){
        Navigator.popAndPushNamed(context, '/login');
      }
      return;
    }

    Uint8List bytesJwt = Utf8Encoder().convert(jwtToken);

    Message msg = Message(0x000B, 0x0000, [bytesJwt]);
    widget.com.send(msg);

    Message? reply =  await widget.com.recv();
   
    if (reply != null && reply.opcode == 0x000B){
      if (reply.status == 0x0001 && mounted){
        Navigator.popAndPushNamed(context, '/home');
      }
    }


    else if (mounted){
      Navigator.popAndPushNamed(context, '/login');
    }
    
  }
}


