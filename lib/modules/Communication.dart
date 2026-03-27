import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
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
    socket.flush(); // async flush, don't await
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

  void _notifyWaiters() {
    for (final w in _waiters) {
      if (!w.isCompleted) w.complete();
    }
  _waiters.clear();
}
  
  // Added: cleanup method
  Future<void> close() async {
    await _subscription.cancel();
    await socket.close();
  }

  static Future<Communication?> restoreCon({int maxRetries = 5}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final s = await Socket.connect("84.229.2.17", 4133)
            .timeout(Duration(seconds: 5));
        final Communication c = await Keyswap.swap(s)
            .timeout(Duration(seconds: 5));
        return c;
      } catch (e) {
        await Future.delayed(Duration(seconds: 2));
      }
    }
    return null; // give up after maxRetries
  }
}