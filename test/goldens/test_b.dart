library typewriter.testing.test_b;

import 'package:typewriter/typewriter.dart';

@Json()
class Person {
  List<String> items;
  double age;
  int coins;
  Dog dog;
  Cat cat;
}

@Json()
class Dog {
  String name;

}

@Json()
class Cat {
  String name;

  @JsonKey('birth_day')
  DateTime birthday;
}
