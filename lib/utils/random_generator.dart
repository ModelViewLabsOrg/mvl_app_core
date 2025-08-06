import 'dart:math';

import 'package:nanoid/async.dart';
import 'package:ulid/ulid.dart';
import 'package:uuid/uuid.dart';

int randomOtp6Numbers() {
  int value = _random();
  while (value < 100000 || value > 999999) {
    value = _random();
  }
  return value;
}

int _random() => (Random().nextDouble() * 1000000).toInt();

Future<String> randomCustomizedId(String alphabet, {int size = 21}) {
  return customAlphabet(alphabet, size);
}

Future<String> randomId({int size = 21}) => nanoid(size);

String randomUuid() => const Uuid().v7();

String randomUlid() => Ulid().toString();
