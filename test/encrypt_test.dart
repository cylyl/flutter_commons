import 'package:encrypt/encrypt.dart' as e;
import 'package:flutter_commons/flutter_commons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Encrypt encrypt = Encrypt.instance;
  final String salt = '[wfS*]-%afhkDg4aCyv}vC;aDWk5aM?:';
  void setup() async {}

  test('encryptDecrypt', () async {
    setup();

    String s = "test";

    String b64 = encrypt.encrypt(salt, s)!;

    final key = e.Key.fromUtf8(salt);
    final iv = e.IV.fromLength(16);

    final encrypter = e.Encrypter(e.AES(key));

    final decrypted = encrypter.decrypt64(b64, iv: iv);

    print(decrypted);
    print(b64);

    assert(decrypted == s);
  });
}
