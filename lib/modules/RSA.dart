import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart';

class RSAHelper {
  /// Generate RSA key pair (2048 bits, exponent 65537)
  static Map<String, Uint8List> generateRSAKeys() {
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(
            BigInt.parse('65537'),
            2048,
            64,
          ),
          _secureRandom(),
        ),
      );

    final pair = keyGen.generateKeyPair();

    final privateKey = pair.privateKey;
    final publicKey = pair.publicKey;

    return {
      'private': _encodePrivateKeyToPem(privateKey),
      'public': _encodePublicKeyToPem(publicKey),
    };
  }

  /// Encrypt with public key (OAEP + SHA256)
  static Uint8List encryptMessage(
    Uint8List message,
    Uint8List publicKeyPem,
  ) {
    final publicKey = _parsePublicKeyFromPem(publicKeyPem);

    final cipher = OAEPEncoding.withSHA256(RSAEngine())
      ..init(
        true,
        PublicKeyParameter<RSAPublicKey>(publicKey),
      );

    return _processInBlocks(cipher, message);
  }

  /// Decrypt with private key (OAEP + SHA256)
  static Uint8List decryptMessage(
    Uint8List encrypted,
    Uint8List privateKeyPem,
  ) {
    final privateKey = _parsePrivateKeyFromPem(privateKeyPem);

    final cipher = OAEPEncoding.withSHA256(RSAEngine())
      ..init(
        false,
        PrivateKeyParameter<RSAPrivateKey>(privateKey),
      );

    return _processInBlocks(cipher, encrypted);
  }

  // ---------- helpers ----------

  static Uint8List _processInBlocks(
    AsymmetricBlockCipher engine,
    Uint8List input,
  ) {
    final blockSize = engine.inputBlockSize;
    final output = <int>[];

    for (int offset = 0; offset < input.length; offset += blockSize) {
      final chunk = input.sublist(
        offset,
        (offset + blockSize > input.length)
            ? input.length
            : offset + blockSize,
      );
      output.addAll(engine.process(chunk));
    }

    return Uint8List.fromList(output);
  }

  static SecureRandom _secureRandom() {
    final rnd = SecureRandom('Fortuna');
    final seed = Uint8List(32);
    for (int i = 0; i < seed.length; i++) {
      seed[i] = DateTime.now().microsecondsSinceEpoch & 0xff;
    }
    rnd.seed(KeyParameter(seed));
    return rnd;
  }

  // ---------- PEM parsing and encoding ----------

  static RSAPublicKey _parsePublicKeyFromPem(Uint8List pem) {
    final pemString = utf8.decode(pem);
    final lines = pemString
        .replaceAll('-----BEGIN PUBLIC KEY-----', '')
        .replaceAll('-----END PUBLIC KEY-----', '')
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .trim();
    
    final bytes = base64.decode(lines);
    final asn1Parser = ASN1Parser(bytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    
    final publicKeyBitString = topLevelSeq.elements[1] as ASN1BitString;
    final publicKeyAsn = ASN1Parser(publicKeyBitString.contentBytes());
    final publicKeySeq = publicKeyAsn.nextObject() as ASN1Sequence;
    
    final modulus = (publicKeySeq.elements[0] as ASN1Integer).valueAsBigInteger;
    final exponent = (publicKeySeq.elements[1] as ASN1Integer).valueAsBigInteger;
    
    return RSAPublicKey(modulus, exponent);
  }

  static RSAPrivateKey _parsePrivateKeyFromPem(Uint8List pem) {
    final pemString = utf8.decode(pem);
    final lines = pemString
        .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
        .replaceAll('-----END RSA PRIVATE KEY-----', '')
        .replaceAll('-----BEGIN PRIVATE KEY-----', '')
        .replaceAll('-----END PRIVATE KEY-----', '')
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .trim();
    
    final bytes = base64.decode(lines);
    final asn1Parser = ASN1Parser(bytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    
    // Handle PKCS#8 format (has extra wrapping)
    ASN1Sequence privateKeySeq;
    if (topLevelSeq.elements.length == 3) {
      // PKCS#8 format
      final privateKeyOctet = topLevelSeq.elements[2] as ASN1OctetString;
      final innerParser = ASN1Parser(privateKeyOctet.octets);
      privateKeySeq = innerParser.nextObject() as ASN1Sequence;
    } else {
      // PKCS#1 format
      privateKeySeq = topLevelSeq;
    }
    
    final modulus = (privateKeySeq.elements[1] as ASN1Integer).valueAsBigInteger;
    final privateExponent = (privateKeySeq.elements[3] as ASN1Integer).valueAsBigInteger;
    final p = (privateKeySeq.elements[4] as ASN1Integer).valueAsBigInteger;
    final q = (privateKeySeq.elements[5] as ASN1Integer).valueAsBigInteger;
    
    return RSAPrivateKey(modulus, privateExponent, p, q);
  }

  static Uint8List _encodePublicKeyToPem(RSAPublicKey key) {
    final algorithmSeq = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromName('rsaEncryption'))
      ..add(ASN1Null());

    final publicKeySeq = ASN1Sequence()
      ..add(ASN1Integer(key.modulus!))
      ..add(ASN1Integer(key.exponent!));

    final publicKeySeqBitString = ASN1BitString(
      Uint8List.fromList(publicKeySeq.encodedBytes),
    );

    final topLevelSeq = ASN1Sequence()
      ..add(algorithmSeq)
      ..add(publicKeySeqBitString);

    final dataBase64 = base64.encode(topLevelSeq.encodedBytes);
    final chunks = <String>[];
    for (int i = 0; i < dataBase64.length; i += 64) {
      chunks.add(
        dataBase64.substring(
          i,
          i + 64 > dataBase64.length ? dataBase64.length : i + 64,
        ),
      );
    }

    final pem = '-----BEGIN PUBLIC KEY-----\n${chunks.join('\n')}\n-----END PUBLIC KEY-----';
    return Uint8List.fromList(utf8.encode(pem));
  }

  static Uint8List _encodePrivateKeyToPem(RSAPrivateKey key) {
    final version = ASN1Integer(BigInt.from(0));
    final modulus = ASN1Integer(key.modulus!);
    final publicExponent = ASN1Integer(key.exponent!);
    final privateExponent = ASN1Integer(key.privateExponent!);
    final p = ASN1Integer(key.p!);
    final q = ASN1Integer(key.q!);
    final dP = ASN1Integer(key.privateExponent! % (key.p! - BigInt.one));
    final dQ = ASN1Integer(key.privateExponent! % (key.q! - BigInt.one));
    final iQ = ASN1Integer(key.q!.modInverse(key.p!));

    final privateKeySeq = ASN1Sequence()
      ..add(version)
      ..add(modulus)
      ..add(publicExponent)
      ..add(privateExponent)
      ..add(p)
      ..add(q)
      ..add(dP)
      ..add(dQ)
      ..add(iQ);

    final dataBase64 = base64.encode(privateKeySeq.encodedBytes);
    final chunks = <String>[];
    for (int i = 0; i < dataBase64.length; i += 64) {
      chunks.add(
        dataBase64.substring(
          i,
          i + 64 > dataBase64.length ? dataBase64.length : i + 64,
        ),
      );
    }

    final pem = '-----BEGIN RSA PRIVATE KEY-----\n${chunks.join('\n')}\n-----END RSA PRIVATE KEY-----';
    return Uint8List.fromList(utf8.encode(pem));
  }
}