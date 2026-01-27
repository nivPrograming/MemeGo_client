//import 'package:flutter/material.dart';
//import 'app/memego.dart';

import 'dart:io';
import 'modules/keySwap.dart';


void main() {
  Socket.connect("127.0.0.1", 4133).then((s){
      Keyswap.swap(s).then((s){
        print(s.key);
      });
  });


  //runApp(const MemeGo());
}
