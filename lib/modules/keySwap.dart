import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';

import 'package:client/models/Message.dart';

import 'Communication.dart';
import 'RSA.dart';
import 'AES.dart';

class Keyswap {
  static Future<Communication> swap(Socket s) async {
    final key = AES.secureRandomBytes(16);
    Communication com = Communication(s, key);

    // Receive RSA public key from server
    Uint8List data = await com.recvBySize();
    Message? raw_msg = Message.loadFromBytes(data);
    
    if (raw_msg == null || raw_msg.fields.isEmpty) {
      throw Exception("Failed to receive RSA public key");
    }

    // Verify opcode and status
    if (raw_msg.opcode != 0x6969 || raw_msg.status != 0x0001) {
      throw Exception("Invalid message format from server");
    }

    Uint8List rsa_pub = raw_msg.fields[0];

    // Encrypt AES key with RSA public key
    Uint8List encKey = RSAHelper.encryptMessage(key, rsa_pub);

    // Send encrypted AES key (status should be 0x0003)
    Message msg = Message(0x6969, 0x0003, [encKey]);
    com.sendWithSize(msg.prepare());

    // Wait for confirmation
    data = await com.recvBySize();
    raw_msg = Message.loadFromBytes(data);

    if (raw_msg == null || raw_msg.fields.isEmpty) {
      throw Exception("Failed to receive confirmation");
    }

    // Check for "OK" response
    if (raw_msg.opcode == 0x6969 && 
        raw_msg.status == 0x0002 && 
        utf8.decode(raw_msg.fields[0]) == "OK") {
      return com;
    }

    throw Exception("Key swap rejected by server");
  }
}