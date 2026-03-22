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
  }

  @override
  void initState() {
    _handleReconnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Authentication')),
      body:Icon(Icons.signal_wifi_connected_no_internet_4_outlined)
    );
  }

}