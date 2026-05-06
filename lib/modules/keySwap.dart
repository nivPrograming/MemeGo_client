import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';

import 'package:client/models/Message.dart';

import 'Communication.dart';
import 'RSA.dart';
import 'AES.dart';

class Keyswap {

  // does an RSA key swap with te server public rsa key
  static Future<Communication> swap(Socket s) async {
    final key = AES.secureRandomBytes(16);
    Communication com = Communication(s, key);

    Uint8List data = await com.recvBySize();
    Message? rawMsg = Message.loadFromBytes(data);
    
    if (rawMsg == null || rawMsg.fields.isEmpty) {
      throw Exception("Failed to receive RSA public key");
    }

    if (rawMsg.opcode != 0x6969 || rawMsg.status != 0x0001) {
      throw Exception("Invalid message format from server");
    }

    Uint8List rsaPub = rawMsg.fields[0];

    Uint8List encKey = RSAHelper.encryptMessage(key, rsaPub);

    Message msg = Message(0x6969, 0x0003, [encKey]);
    com.sendWithSize(msg.prepare());

    data = await com.recvBySize();
    rawMsg = Message.loadFromBytes(data);

    if (rawMsg == null || rawMsg.fields.isEmpty) {
      throw Exception("Failed to receive confirmation");
    }

    if (rawMsg.opcode == 0x6969 && 
        rawMsg.status == 0x0002 && 
        utf8.decode(rawMsg.fields[0]) == "OK") {
      return com;
    }

    throw Exception("Key swap rejected by server");
  }
}