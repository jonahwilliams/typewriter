import 'item.dart';
import 'dog.dart';
import 'package:typewriter/annotations/annotations.dart';

class Person {
  String name;
  int age;
  double money;
  @JsonKey('is_alive')
  bool isAlive;
  Item item;
  Dog dog;
  Symbol opaque;
}
