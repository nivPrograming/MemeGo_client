import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'storage.dart';
import '../../modules/Communication.dart';
import '../../modules/json_helper.dart';
import '../../models/Message.dart';
import '../../models/data_base_types.dart';
import '../../widgets/appState.dart';

class StoragePageState extends State<StoragePage> {

  late Size _size;
  late EdgeInsets _padding;
  late double _width;
  late double _height;


  List<Row> _images = [];
  List<CreaturesCaught> _creatures = [];

  @override
  void initState(){
    super.initState();
    getCreatures();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _padding = MediaQuery.of(context).padding;
    _width = _size.width;
    _height = _size.height - _padding.bottom - _padding.top;

    return Scaffold(
      appBar: AppBar(title: const Text('Creature Inventory')),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: _images,
        )
      )
    );
  }

  Future<void> getCreatures() async{
    Message msg = Message(0x0006, 0x0000);
    context.read<AppState>().com.send(msg);

    Message? reply = await context.read<AppState>().com.recv();
    if (reply != null && reply.opcode == 0x0006 && reply.status == 0x0001){
      for (int i = 0; i < reply.fields.length; i++){
        _creatures.add(CreaturesCaught.fromBytes(reply.fields[i]));
      }

      buildScroll();
    }

    else if (reply == null && mounted){
       Navigator.popAndPushNamed(context, '/reconnect');
    }
  }

  Future<void> buildScroll() async{
    List<Row> newImages = [];
    for (int i = 0; i < _creatures.length; i += 2){
      Map<String, dynamic>? creature1Type = await readJsonFile("Creatures/${_creatures[i].type.toString().padLeft(4, "0")}.json");
      Map<String, dynamic>? creature2Type;

      if (i + 1 < _creatures.length){
        creature2Type = await readJsonFile("Creatures/${_creatures[i+1].type.toString().padLeft(4, "0")}.json");
      }

      newImages.add(Row(
        children: 
          [
            Column(children: [Image.asset("Creatures/${creature1Type!["photo"]}", width: _width * 0.4, height: _height * 0.3), Text(creature1Type["name"]), Text("${_creatures[i].resiliencePoints}")]),
            creature2Type != null
            ?  Column(children: [Image.asset("Creatures/${creature2Type["photo"]}", width: _width * 0.4, height: _height * 0.3), Text(creature2Type["name"]), Text("${_creatures[i + 1].resiliencePoints}")])
            : SizedBox(width: _width * 0.4, height: _height * 0.3)
          ],
        )
      );
    }

    setState(() {
      _images = newImages;
    });
  }

}
