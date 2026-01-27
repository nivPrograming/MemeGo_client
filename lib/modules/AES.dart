import 'dart:typed_data';
import 'dart:math';
import 'package:pointycastle/export.dart';

class AES {
  /// PKCS7 padding (block size = 16 bytes)
  static Uint8List _pad(Uint8List data) {
    const blockSize = 16;
    final padLen = blockSize - (data.length % blockSize);
    return Uint8List.fromList(data + List.filled(padLen, padLen));
  }

  static Uint8List _unpad(Uint8List data) {
    final padLen = data.last;
    return data.sublist(0, data.length - padLen);
  }

  /// AES-CBC Encrypt (returns IV + ciphertext)
  static Uint8List aesCbcEncrypt(Uint8List plaintext, Uint8List key) {
    final iv = secureRandomBytes(16);

    final cipher = CBCBlockCipher(AESEngine())
      ..init(
        true,
        ParametersWithIV(KeyParameter(key), iv),
      );

    final padded = _pad(plaintext);
    final output = Uint8List(padded.length);

    for (int i = 0; i < padded.length; i += 16) {
      cipher.processBlock(padded, i, output, i);
    }

    // IV || ciphertext
    return Uint8List.fromList(iv + output);
  }

  /// AES-CBC Decrypt (expects IV + ciphertext)
  static Uint8List aesCbcDecrypt(Uint8List ciphertext, Uint8List key) {
    final iv = ciphertext.sublist(0, 16);
    final encrypted = ciphertext.sublist(16);

    final cipher = CBCBlockCipher(AESEngine())
      ..init(
        false,
        ParametersWithIV(KeyParameter(key), iv),
      );

    final output = Uint8List(encrypted.length);

    for (int i = 0; i < encrypted.length; i += 16) {
      cipher.processBlock(encrypted, i, output, i);
    }

    return _unpad(output);
  }

  /// Cryptographically secure random bytes
  static Uint8List secureRandomBytes(int length) {
    final rnd = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = rnd.nextInt(256);
    }
    return bytes;
  }
}