import 'dart:convert';
import 'dart:typed_data';

Uint8List base64ToImage(String base64String) {
  final cleanBase64 = base64String.split(',').last;
  return base64Decode(cleanBase64);
}
