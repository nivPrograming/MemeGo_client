
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';


import '../../modules/Communication.dart';
import '../../models/Message.dart';
import '../../models/data_base_types.dart';
import '../../widgets/appState.dart';


import "../../modules/json_helper.dart";
import "../../modules/jwt_storage.dart";


class HomeState extends State<HomePage>{

  Timer? _dataFetchTimer;

  double _lat = 32.0753;
  double _lon = 34.7718;
  List<Marker> markers = [];
  final MapController _mapController = MapController();
  StreamSubscription<Position>? positionStream;
  bool _isMapReady = false;

  void _updateCreatures() async{
    ByteData bytesLat = ByteData(8);
    bytesLat.setFloat64(0, _lat, Endian.big);
    ByteData bytesLon = ByteData(8);
    bytesLon.setFloat64(0, _lon, Endian.big);
    
    List<Marker> newCretures = [Marker(point: LatLng(_lat,_lon),
                      width: 60.0,
                      height: 60.0,
                      child: Icon(Icons.shield))];
    markers = [];

    final msg = Message(0x0007, 0x0000,[bytesLat.buffer.asUint8List(), bytesLon.buffer.asUint8List()]);
    context.read<AppState>().com.send(msg);

    Message? retData = await context.read<AppState>().com.recv();

    if (retData != null && retData.opcode == 0x0007 && retData.status == 0x0001 && retData.fields.isNotEmpty){
     

      for (Uint8List creatureData in retData.fields){
        CreaturesInTheWild creature = CreaturesInTheWild.fromBytes(creatureData);

        Map<String, dynamic>? creatureType =  await readJsonFile("Creatures/${creature.type.toString().padLeft(4,'0')}.json");

        if (creatureType != null && creatureType.containsKey('photo')){
          newCretures.add(Marker(point: LatLng(creature.lat,creature.lon),
                                width: 60.0,
                                height: 60.0, 
                                child: GestureDetector(
                                  onTap: () => Navigator.popAndPushNamed(context, '/catch', arguments: creature),
                                  child: Image.asset("Creatures/${creatureType['photo']}"),
                                )
                                )
                          );
        }
      }
     
      setState(() {
        markers = newCretures;
      });
    }

    else if (retData == null && mounted){
      Navigator.popAndPushNamed(context, '/reconnect');
    }
  }


   @override
  void initState() {
    super.initState();
  
    _dataFetchTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _updateCreatures();
    });

    checkGPSPermissions().then((v) {
      positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      ).listen((Position pos) {
        setState(() {
          _lat = pos.latitude;
          _lon= pos.longitude; 
        });

        if (_isMapReady) {
          try {
            _mapController.move(LatLng(_lat, _lon), _mapController.camera.zoom);
          } catch (e) {
            print("Map not ready yet: $e");
          }
      } 
      });
    });
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, title: Text("meme mapping"),),
        body: FlutterMap(options: MapOptions(
            initialCenter: LatLng(_lat, _lon),
            initialZoom: 16,
            onMapReady: () => setState(() {
              _isMapReady = true;
            })
            ),
            mapController: _mapController,
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
    positionStream?.cancel();
    super.dispose();
  }


  void handleNavBar(int index){
      switch (index){
        case 0:
          break;
        case 1:
          Navigator.pushNamed(context, "/storage");
          break;
        case 2:
          logout();
          break;
      }
  }

  void logout() async{
    Message msg = Message(0x000A, 0x0000);
    context.read<AppState>().com.send(msg);

    Message? reply = await context.read<AppState>().com.recv();
    JwtStorage().delete();
    if (mounted){
      Navigator.popAndPushNamed(context, "/login");
    }
    
  }

  Future<void> checkGPSPermissions() async{
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
  } 
  
}