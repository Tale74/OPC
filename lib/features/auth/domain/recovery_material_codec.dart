import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class RecoveryMaterialSecret {
  const RecoveryMaterialSecret({
    required this.plaintext,
    required this.hash,
    required this.salt,
    required this.version,
  });

  final String plaintext;
  final String hash;
  final String salt;
  final String version;
}

class RecoveryMaterialCodec {
  RecoveryMaterialCodec({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  static const String version = 'PBKDF2_SHA256_V1';
  static const int _saltLength = 16;
  static const int _iterations = 120000;
  static const String _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  RecoveryMaterialSecret generate() {
    final plaintext = _generateRecoveryCode();
    final saltBytes = _generateBytes(_saltLength);
    final hash = _deriveHash(plaintext, saltBytes);
    return RecoveryMaterialSecret(
      plaintext: plaintext,
      hash: hash,
      salt: base64Encode(saltBytes),
      version: version,
    );
  }

  bool verify({
    required String plaintext,
    required String hash,
    required String salt,
    required String storedVersion,
  }) {
    if (storedVersion != RecoveryMaterialCodec.version) {
      return false;
    }
    final saltBytes = base64Decode(salt);
    final expected = _deriveHash(plaintext, saltBytes);
    return expected == hash;
  }

  String _generateRecoveryCode() {
    final segments = List<String>.generate(4, (_) {
      final buffer = StringBuffer();
      for (var i = 0; i < 4; i++) {
        buffer.write(_alphabet[_random.nextInt(_alphabet.length)]);
      }
      return buffer.toString();
    });
    return segments.join('-');
  }

  Uint8List _generateBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  String _deriveHash(String plaintext, Uint8List saltBytes) {
    final secretBytes = Uint8List.fromList(utf8.encode(plaintext));
    final derived = _pbkdf2(
      secretBytes,
      saltBytes,
      iterations: _iterations,
      keyLength: 32,
    );
    return base64Encode(derived);
  }

  Uint8List _pbkdf2(
    Uint8List password,
    Uint8List salt, {
    required int iterations,
    required int keyLength,
  }) {
    final hmac = Hmac(sha256, password);
    const hashLength = 32;
    final blockCount = (keyLength / hashLength).ceil();
    final output = BytesBuilder(copy: false);

    for (var blockIndex = 1; blockIndex <= blockCount; blockIndex++) {
      final block = BytesBuilder(copy: false)
        ..add(salt)
        ..add(_int32be(blockIndex));
      var u = Uint8List.fromList(hmac.convert(block.toBytes()).bytes);
      final t = Uint8List.fromList(u);

      for (var i = 1; i < iterations; i++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var j = 0; j < t.length; j++) {
          t[j] = t[j] ^ u[j];
        }
      }

      output.add(t);
    }

    final bytes = output.toBytes();
    return Uint8List.sublistView(bytes, 0, keyLength);
  }

  Uint8List _int32be(int value) {
    return Uint8List.fromList([
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ]);
  }
}
