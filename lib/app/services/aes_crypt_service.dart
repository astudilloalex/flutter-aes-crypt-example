import 'dart:convert';
import 'dart:math' hide log;
import 'dart:typed_data';

import 'package:aes_screen/src/common/domain/aes_mode_enum.dart';
import 'package:aes_screen/src/common/domain/padding_enum.dart';
import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart';

class AesCryptService {
  const AesCryptService({
    this.ivSizeByte = 12,
  });

  final int ivSizeByte;

  Future<String> encrypt({
    required String key,
    required String plainText,
    PaddingEnum? padding,
    AesModeEnum mode = AesModeEnum.gcm,
  }) async {
    switch (mode) {
      case AesModeEnum.gcm:
        return _encryptWithAESGCM(phrase: key, plainText: plainText);
      case AesModeEnum.cbc:
        return _encryptWithAESCBC(phrase: key, plainText: plainText);
      default:
        throw UnimplementedError('Not implemented mode');
    }
  }

  Future<String> decrypt({
    required String key,
    required String cipherText,
    PaddingEnum? padding,
    AesModeEnum mode = AesModeEnum.gcm,
  }) async {
    switch (mode) {
      case AesModeEnum.gcm:
        return _decryptFromAESGCM(phrase: key, cipherText: cipherText);
      case AesModeEnum.cbc:
        return _decryptFromAESCBC(phrase: key, cipherText: cipherText);
      default:
        throw UnimplementedError('Not implemented mode');
    }
  }

  Future<String> _encryptWithAESGCM({
    required String phrase,
    required String plainText,
  }) async {
    final AesGcm aesGcm = AesGcm.with256bits();
    final SecretBox secretBox = await aesGcm.encrypt(
      utf8.encode(plainText),
      secretKey: SecretKey(_generateKeyFromPhrase(phrase)),
      nonce: aesGcm.newNonce(),
    );
    return base64.encode(
      Uint8List.fromList(
        secretBox.nonce + secretBox.cipherText + secretBox.mac.bytes,
      ),
    );
  }

  Future<String> _decryptFromAESGCM({
    required String phrase,
    required String cipherText,
  }) async {
    final Uint8List cipherTextBytes = base64.decode(cipherText);
    final AesGcm aesGcm = AesGcm.with256bits();
    final SecretBox secretBox = SecretBox(
      cipherTextBytes.sublist(12, cipherTextBytes.length - 16),
      nonce: cipherTextBytes.sublist(0, 12),
      mac: Mac(cipherTextBytes.sublist(cipherTextBytes.length - 16)),
    );
    final List<int> decrypted = await aesGcm.decrypt(
      secretBox,
      secretKey: SecretKey(_generateKeyFromPhrase(phrase)),
    );
    return utf8.decode(decrypted);
  }

  String _encryptWithAESCBC({
    required String phrase,
    required String plainText,
  }) {
    Encrypter encrypter = Encrypter(
      AES(
        Key.fromUtf8(phrase),
        mode: AESMode.cbc,
      ),
    );
    return encrypter.encrypt(plainText, iv: IV.fromLength(16)).base64;
  }

  String _decryptFromAESCBC({
    required String phrase,
    required String cipherText,
  }) {
    Encrypter encrypter = Encrypter(
      AES(
        Key.fromUtf8(phrase),
        mode: AESMode.cbc,
      ),
    );
    return encrypter.decrypt(
      Encrypted.from64(cipherText),
      iv: IV.fromLength(16),
    );
  }

  List<int> _generateKeyFromPhrase(String phrase) {
    if (phrase.length < 32) {
      throw ArgumentError('Invalid phrase length');
    }
    return utf8.encode(phrase).sublist(0, 32);
  }

  Uint8List _generateIV({
    int size = 12,
  }) {
    final Random random = Random.secure();
    final List<int> iv = List<int>.generate(
      size,
      (_) => random.nextInt(256),
    );
    return Uint8List.fromList(iv);
  }
}
