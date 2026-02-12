import 'package:client/modules/Communication.dart';
import 'package:flutter/material.dart';
import 'homestate.dart';


class HomePage extends StatefulWidget {

  final Communication com;

  const HomePage({
    super.key,
    required this.com,
  });


  @override
  State<StatefulWidget> createState() => HomeState();
  
}