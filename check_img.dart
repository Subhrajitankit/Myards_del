import 'dart:io';

void main() {
  var bytes = File('assets/image/logolauncher.png').readAsBytesSync();
  print('logolauncher.png length: ' + bytes.length.toString());
}
