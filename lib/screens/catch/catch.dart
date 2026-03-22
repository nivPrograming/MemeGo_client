import 'package:client/models/data_base_types.dart';
import 'package:flutter/material.dart';
import 'catch_state.dart';

class CatchPage extends StatefulWidget {
  final CreaturesInTheWild creature;

  const CatchPage({
    super.key,
    required this.creature
  });

  @override
  State<CatchPage> createState() => CatchPageState();
}
