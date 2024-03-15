import 'package:flutter_commons/flutter_commons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final String salt = '[wfS*]-%afhkDg4aCyv}vC;aDWk5aM?:';
  void setup() async {}

  test('encryptDecrypt', () async {
    setup();

    String s = "test";

    Encrypt encrypt = Encrypt.instance;
    String? b64 = encrypt.encrypt(salt, s);
    String? decrypted = encrypt.decrypt(salt, b64!);
    print(decrypted);
    print(b64);

    assert(decrypted == s);

  });
}
