import 'package:typewriter/annotations/annotations.dart';

@Json()
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
  Foo myFoo;
}


@Json()
class Foo {
  final int x;
  final int y;

  Foo._(this.x, this.y);

  @JsonEncoder()
  Object encode() {
    return {'x': x, 'y': y};
  }

  @JsonDecoder()
  factory Foo(Object raw) {
    final input = raw as Map<String, dynamic>;
    return new Foo._(input['x'] ?? 0, input['y'] ?? 1);
  }
}
