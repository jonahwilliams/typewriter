library typewriter.example.person;

import 'dart:convert';
import 'package:typewriter/annotations.dart';
part 'person.json.g.dart';

@deriveJson()
class Person {
  String name;
  int age;
  double money;
  @jsonProperty('is_alive')
  bool isAlive;
  Symbol opaque;
}
