import 'package:flutter/material.dart';
import 'home.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';
import 'dart:async';


import '../../modules/Communication.dart';
import '../../models/Message.dart';
import '../../models/data_base_types.dart';

import "../../modules/json_helper.dart";
import "../../modules/jwt_storage.dart";


class HomeState extends State<HomePage>{

  Timer? _dataFetchTimer;

  double lat = 32.0753;
  double lon = 34.7718;
  List<Marker> markers = [];


  void _updateCreatures() async{
    ByteData bytesLat = ByteData(8);
    bytesLat.setFloat64(0, lat, Endian.big);
    ByteData bytesLon = ByteData(8);
    bytesLon.setFloat64(0, lon, Endian.big);

    final msg = Message(0x0007, 0x0000,[bytesLat.buffer.asUint8List(), bytesLon.buffer.asUint8List()]);
    widget.com.send(msg);

    Message? retData = await widget.com.recv();

    if (retData != null){
      List<Marker> newCretures = [];

      for (Uint8List creatureData in retData.fields){
        CreaturesInTheWild creature = CreaturesInTheWild.fromBytes(creatureData);

        Map<String, dynamic>? creatureType =  await readJsonFile("Creatures/${creature.type.toString().padLeft(4,'0')}.json");

        if (creatureType != null && creatureType.containsKey('photo')){
          newCretures.add(Marker(point: LatLng(creature.lat,creature.lon),
                                width: 60.0,
                                height: 60.0, 
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/catch', arguments: creature),
                                  child: Image.asset("Creatures/${creatureType['photo']}"),
                                )
                                )
                          );
        }
      }
      newCretures.add(Marker(point: LatLng(lat,lon),
                                width: 60.0,
                                height: 60.0,
                                child: Icon(Icons.shield)));
      setState(() {
        markers = newCretures;
      });
    }

    else{

    }
      
  }


   @override
  void initState() {
    super.initState();
  
    // Fetch data every 20 seconds
    _dataFetchTimer = Timer.periodic(Duration(seconds: 20), (timer) {
      _updateCreatures();
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, title: Text("meme mapping"),),
        body: FlutterMap(options: MapOptions(
            initialCenter: LatLng(lat, lon), // Tel Aviv
            initialZoom: 16 ),
            children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.memego.memecatch',
            ),
             MarkerLayer(markers: 
              markers
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(items: [
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
            BottomNavigationBarItem(icon: Icon(Icons.archive_sharp), label: "Storage"),
            BottomNavigationBarItem(icon: Icon(Icons.exit_to_app_sharp), label: "log out")
          ],
          onTap: handleNavBar
          ,
        ),
      );
  }

@override
  void dispose() {
    _dataFetchTimer?.cancel();
    super.dispose();
  }


  void handleNavBar(int index){
      switch (index){
        case 0:
          break;
        case 1:
          break;
        case 2:
          logout();
          break;
      }
  }

  void logout() async{
    Message msg = Message(0x000A, 0x0000);
    widget.com.send(msg);

    Message? reply = await widget.com.recv();
    JwtStorage().delete();
    if (mounted){
      Navigator.popAndPushNamed(context, "/login");
    }
    
  }
  
}