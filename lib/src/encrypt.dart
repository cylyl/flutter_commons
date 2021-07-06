import 'package:encrypt/encrypt.dart';

class Encrypt {
  static final Encrypt instance = Encrypt._();
  final iv = IV.fromLength(16);

  Encrypt._() {}

  get _encrypter => (salt) {
        final key = Key.fromUtf8(salt);
        return Encrypter(AES(key));
      };

  String? encrypt(String salt, String s) {
    return _encrypter(salt).encrypt(s, iv: iv).base64;
  }

  String? decrypt(String salt, String b64) {
    return _encrypter(salt).decrypt64(b64, iv: iv);
  }
}
