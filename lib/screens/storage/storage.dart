import 'package:flutter/material.dart';
import 'storage_state.dart';
import '../../modules/Communication.dart';

class StoragePage extends StatefulWidget {
 final Communication com;

  const StoragePage({
    super.key,
    required this.com,
  });

  @override
  State<StoragePage> createState() => StoragePageState();
}

