import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.deepOrange, title: Text("meme mapping"),),
        body: FlutterMap(options: MapOptions(
            initialCenter: LatLng(32.0853, 34.7818), // Tel Aviv
            initialZoom: 13 ),
            children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.memego.memecatch',
            ),
             MarkerLayer(markers: [
              Marker(point: LatLng(32.1, 34.8), child: Icon(Icons.place_outlined))
            ]),
          ],
        )
      )
    );
  }
}