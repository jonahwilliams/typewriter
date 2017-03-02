import 'package:typewriter/annotations/annotations.dart';

@Json()
class Person {
  String name;
  int age;
  double money;
  @PropertyJson('is_alive')
  bool isAlive;
  Item item;
  Dog dog;
  Symbol opaque;
}

@Xml()
@Json()
class Item {
  String name;
  int id;
  String description;
  RegExp why;

  @Ignore()
  String other;
}

@Json()
class Dog {
  List<String> names;
  double age;
  DateTime birthday;
}
