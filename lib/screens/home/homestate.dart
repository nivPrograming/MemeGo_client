import 'package:flutter/material.dart';
import 'home.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';

import '../../modules/Communication.dart';
import '../../models/Message.dart';
import '../../models/data_base_types.dart';


class HomeState extends State<HomePage>{
  @override
  Widget build(BuildContext context){
  double lat = 32.0853;
  double lon = 34.7818;
  List<Marker> markers = [Marker(point: LatLng(lat, lon), child: Icon(Icons.airplanemode_active))];

    ByteData bytesLat = ByteData(8);
    bytesLat.setFloat64(0, lat, Endian.big);
    ByteData bytesLon = ByteData(8);
    bytesLon.setFloat64(0, lon, Endian.big);

    final msg = Message(0x0007, 0x0000,[bytesLat.buffer.asUint8List(), bytesLon.buffer.asUint8List()]);
    widget.com.send(msg);

    widget.com.recv().then((value){
      if (value != null){
        print(value.opcode);
        print(value.status);
      }
    });


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.deepOrange, title: Text("meme mapping"),),
        body: FlutterMap(options: MapOptions(
            initialCenter: LatLng(lat, lon), // Tel Aviv
            initialZoom: 13 ),
            children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.memego.memecatch',
            ),
             MarkerLayer(markers: 
              markers
            ),
          ],
        )
      )
    );
  }
  
}