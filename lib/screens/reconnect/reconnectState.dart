import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reconnect.dart';

import '../../widgets/appState.dart';
import '../../modules/Communication.dart';




class ReconnectState extends State<ReconnectPage>{

  

  @override
  void dispose() {
    super.dispose();
  }

  
  void _handleReconnection() async {
     Communication? newCom = await Communication.restoreCon();
      if (newCom != null && mounted){
        context.read<AppState>().replaceCom(newCom);
        Navigator.popAndPushNamed(context, '/verify_token');
      }

      else if(mounted){
        Navigator.pop(context);
      }
  }

  @override
  void initState() {
    _handleReconnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    EdgeInsets padding = MediaQuery.of(context).padding;
    final double width = size.width;
    final double height = size.height - padding.bottom - padding.top;

    return Scaffold(
      appBar: AppBar(title: const Text('RECONNECTING')),
      body:SizedBox(
        width: width,
        height: height,
        child: Icon(Icons.signal_wifi_connected_no_internet_4_outlined),
        
        )
    );
  }

}