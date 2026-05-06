import 'dart:typed_data';
import 'dart:math';
import 'package:pointycastle/export.dart';

class AES {
   // Encrypts data using AES-GCM
  static Uint8List aesGcmEncrypt(Uint8List data, Uint8List key) {
    final nonce = secureRandomBytes(12);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)),
      );

    final output = Uint8List(cipher.getOutputSize(data.length));
    final len = cipher.processBytes(data, 0, data.length, output, 0);
    final finalLen = len + cipher.doFinal(output, len);

    final ciphertextWithTag = output.sublist(0, finalLen);

    return Uint8List.fromList(nonce + ciphertextWithTag);
  }

  // Decrypts AES-GCM data, expects nonce prepended to ciphertext + tag
  static Uint8List aesGcmDecrypt(Uint8List data, Uint8List key) {
    final nonce = data.sublist(0, 12);
    final ciphertextWithTag = data.sublist(12);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)),
      );

    final output = Uint8List(cipher.getOutputSize(ciphertextWithTag.length));
    final len = cipher.processBytes(ciphertextWithTag, 0, ciphertextWithTag.length, output, 0);
    final finalLen = len + cipher.doFinal(output, len);
    return output.sublist(0, finalLen);
  }

  // Generates cryptographically secure random bytes of given length
  static Uint8List secureRandomBytes(int length) {
    final rnd = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => rnd.nextInt(256)));
  }
}