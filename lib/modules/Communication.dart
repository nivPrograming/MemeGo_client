import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import '../models/Message.dart';
import 'AES.dart';


class Communication {
  static const int sizeHeaderSize = 4;

  final Socket socket;
  final Uint8List key;
  
  // Added: buffer and subscription to listen once
  final List<int> _buffer = [];
  late StreamSubscription _subscription;
  bool _isClosed = false;

  Communication(this.socket, this.key) {
    // Added: listen to socket once in constructor
    _subscription = socket.listen(
      (chunk) => _buffer.addAll(chunk),
      onError: (_) => _isClosed = true,
      onDone: () => _isClosed = true,
    );
  }

  /// Send Message
  void send(Message msg) {
    final plain = msg.prepare();
    final encrypted = AES.aesCbcEncrypt(plain, key);

    sendWithSize(encrypted);
  }

  /// Receive Message
  Future<Message?> recv() async {
    final encrypted = await recvBySize();
    if (encrypted.isEmpty) return null;

    final decrypted = AES.aesCbcDecrypt(encrypted, key);
    return Message.loadFromBytes(decrypted);
  }

  /// ---- framing ----

  void sendWithSize(Uint8List data) {
    final header = ByteData(4)..setUint32(0, data.length, Endian.big);
    socket.add(header.buffer.asUint8List());
    socket.add(data);
  }

  Future<Uint8List> recvBySize() async {
    final header = await _readExact(4);
    if (header.isEmpty) return Uint8List(0);

    final len = ByteData.sublistView(header).getUint32(0, Endian.big);
    final body = await _readExact(len);

    return body.length == len ? body : Uint8List(0);
  }

  // Changed: now reads from buffer instead of listening to socket
  Future<Uint8List> _readExact(int n) async {
    while (_buffer.length < n && !_isClosed) {
      await Future.delayed(Duration(milliseconds: 10));
    }

    if (_isClosed && _buffer.length < n) {
      return Uint8List(0);
    }

    final result = Uint8List.fromList(_buffer.sublist(0, n));
    _buffer.removeRange(0, n);
    
    return result;
  }
  
  // Added: cleanup method
  Future<void> close() async {
    await _subscription.cancel();
    await socket.close();
  }
}