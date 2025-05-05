import 'dart:math';
import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class TOTPGenerator {
  static String generate(String secret) {
    final key = base32.decode(secret);
    final time = (DateTime.now().millisecondsSinceEpoch / 30000).floor();
    final msg = _intToBytes(time);
    
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(msg);
    
    final offset = digest.bytes[digest.bytes.length - 1] & 0xf;
    final code = ((digest.bytes[offset] & 0x7f) << 24 |
        (digest.bytes[offset + 1] & 0xff) << 16 |
        (digest.bytes[offset + 2] & 0xff) << 8 |
        (digest.bytes[offset + 3] & 0xff));
    
    return (code % 1000000).toString().padLeft(6, '0');
  }

  static List<int> _intToBytes(int num) {
    final byteArray = List<int>.filled(8, 0);
    for (int i = 7; i >= 0; i--) {
      byteArray[i] = num & 0xff;
      num = (num >> 8);
    }
    return byteArray;
  }
}