import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import "package:flutter/services.dart";
import '../models/Message.dart';
import 'AES.dart';
import '../modules/keySwap.dart';


class Communication {
  static const int sizeHeaderSize = 4;

  final Socket socket;
  final Uint8List key;
  
  final List<int> _buffer = [];
  late StreamSubscription _subscription;
  final List<Completer<void>> _waiters = [];

  bool _isClosed = false;


  // Constructor, setups the socket listener
  Communication(this.socket, this.key) {
    _subscription = socket.listen(
  (chunk) {
    _buffer.addAll(chunk);
    _notifyWaiters(); // wake up any waiting recv
  },
  onError: (_) {
    _isClosed = true;
    _notifyWaiters();
  },
  onDone: () {
    _isClosed = true;
    _notifyWaiters();
  },
);
  }

  /// Send Message
  void send(Message msg) {
  try {
    final plain = msg.prepare();
    final encrypted = AES.aesGcmEncrypt(plain, key);
    sendWithSize(encrypted);
    socket.flush(); 
  } catch (e) {
    _isClosed = true;
    _notifyWaiters();
  }
}
  /// Receive Message
  Future<Message?> recv() async {
    final encrypted = await recvBySize();
    if (encrypted.isEmpty) return null;

    final decrypted = AES.aesGcmDecrypt(encrypted, key);
    return Message.loadFromBytes(decrypted);
  }

  //Sends data prefixed with a 4-byte big-endian size header
  void sendWithSize(Uint8List data) {
    final header = ByteData(4)..setUint32(0, data.length, Endian.big);
    socket.add(header.buffer.asUint8List());
    socket.add(data);
  }

  // Reads the size header then reads exactly that many bytes
  Future<Uint8List> recvBySize() async {
    final header = await _readExact(4);
    if (header.isEmpty) return Uint8List(0);

    final len = ByteData.sublistView(header).getUint32(0, Endian.big);
    final body = await _readExact(len);

    return body.length == len ? body : Uint8List(0);
  }

    // Waits until exactly n bytes are in the buffer, times out after 5 seconds
  Future<Uint8List> _readExact(int n) async {
    Timer? timer;
  
    timer = Timer(Duration(seconds: 5), () {
      _isClosed = true;
      _notifyWaiters();
    });

    while (_buffer.length < n && !_isClosed) {
      final completer = Completer<void>();
      _waiters.add(completer);
      await completer.future;
    }

    timer.cancel();

    if (_isClosed && _buffer.length < n) return Uint8List(0);

    final result = Uint8List.fromList(_buffer.sublist(0, n));
    _buffer.removeRange(0, n);
    return result;
  }

  // Wakes up all pending recv calls waiting for data
  void _notifyWaiters() {
    for (final w in _waiters) {
      if (!w.isCompleted) w.complete();
    }
  _waiters.clear();
}
  
  // Cancels the socket subscription and closes the connection
  Future<void> close() async {
    await _subscription.cancel();
    await socket.close();
  }

   // Attempts to reconnect to the server.
  static Future<Communication?> restoreCon({int maxRetries = 5}) async {

    String? ip = await _readIP("assets/IP.txt");

    ip ??= "84.229.2.17";
    

    for (int i = 0; i < maxRetries; i++) {
      try {
        final s = await Socket.connect(ip, 4133)
            .timeout(Duration(seconds: 5));
        final Communication c = await Keyswap.swap(s)
            .timeout(Duration(seconds: 5));
        return c;
      } catch (e) {
        await Future.delayed(Duration(seconds: 2));
      }
    }
    return null; 
  }

  // reads the  IP from the assets IP.txt file
  static Future<String?> _readIP(String filePath) async{
    try {
      
      final contents = await rootBundle.loadString(filePath);
      return contents;
    }
    catch (e) {
      print('Error reading file: $e');
    }
    return null;
  }
}