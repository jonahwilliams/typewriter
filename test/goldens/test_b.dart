library typewriter.testing.test_b;

import 'package:typewriter/typewriter.dart';
import 'dart:convert';

@Json()
class Person {
  List<String> items;
  double age;
  int coins;
  Dog dog;
  Cat cat;
}

@Json(useCustomCodec: true)
class Dog {
  final String name;

  @JsonDecode()
  factory Dog(Object raw) {
    return new Dog._(raw as String);
  }

  Dog._(this.name);

  @JsonEncode()
  Object encode() { return name; }

}

@Json()
class Cat {
  String name;

  @JsonKey('birth_day')
  DateTime birthday;
}
