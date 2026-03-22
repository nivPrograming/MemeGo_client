import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:provider/provider.dart';
import 'dart:async';

import 'catch.dart';
import '../../modules/Communication.dart';
import '../../models/Message.dart';
import '../../models/data_base_types.dart';
import '../../modules/json_helper.dart';
import '../../widgets/appState.dart';



class CatchPageState extends State<CatchPage> {
  late Size _size;
  late EdgeInsets _padding;

  double _creatureX = 0.5;
  double _creatureY = 0.5;

  Vector2 dir = Vector2(1,0);
  double speed = 0.025;

  Timer? _dataFetchTimer;
  Map<String, dynamic>? creatureType;

  @override
  void dispose() {
    _dataFetchTimer?.cancel();
    super.dispose();
  }

   @override
  void initState() {
    super.initState();
  
    // Fetch data every 20 seconds
    _dataFetchTimer = Timer.periodic(Duration(milliseconds: 33), (timer) {
      _updateCreature();
    });

    readJsonFile("Creatures/${widget.creature.type.toString().padLeft(4,'0')}.json").then((s){ creatureType = s;});
  }

  @override
  Widget build(BuildContext context){
    _size = MediaQuery.of(context).size;
    _padding = MediaQuery.of(context).padding;
    final double width = _size.width;
    final double height = _size.height - _padding.bottom - _padding.top;


    return Scaffold(appBar: AppBar(
        title: Text("Catch that creature"),
      ),
      body: Stack(
        children: [
          Positioned(  // Catch button
            top: 0.8 * height,
            left: 0.43 * width,
            child: SizedBox(
              width: 0.14 * width,
              height: 0.14 * width,
              child: ElevatedButton(
                onPressed: _handleCatch,
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.grey,
                ),
                child: SizedBox.shrink()
              )
            )
          ),

          Positioned( //Catch box
            top: 0.5 * (height - width * 0.2),
            left: 0.5 * (width * 0.8),
            child: Icon(Icons.rectangle, color: Colors.blueGrey, size: width * 0.2)
          ),

          Positioned( //Creature picture moving around
            top: _creatureY * (height - width * 0.15),
            left: _creatureX * (width * 0.85),
            child: creatureType != null
              ? Image.asset("Creatures/${creatureType!['photo']}", 
              width: width * 0.15,
              height:width * 0.15
            ,)
              : Icon(Icons.star, color: Colors.red, size: width * 0.15)
          ), 

         
      ],
      ),
    );
  }


  void _handleCatch() async{
    if ((_creatureX - 0.5).abs() < 0.05 && (_creatureX - 0.5).abs() < 0.05){

        Message msg = Message(0x0008, 0x0000, [widget.creature.toBytes()]);
        context.read<AppState>().com.send(msg);
        Message? reply =  await context.read<AppState>().com.recv();

        if (mounted && reply != null && reply.opcode == 0x0008 && reply.status == 0x0001){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Caught successfully!'))
          );

          Navigator.popAndPushNamed(context, '/home');
        }

        else if (reply == null && mounted){
          Navigator.popAndPushNamed(context, '/reconnect');
        }

        else if (mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OPSSSS, No Catch for you today'))
          );

          Navigator.popAndPushNamed(context, '/home');
        }

      }
    }


  void _updateCreature(){
    setState(() {
      _creatureX = (_creatureX + dir.x * speed) % 1;
      _creatureY = (_creatureY + dir.y * speed) % 1;
    });
    
  }
}