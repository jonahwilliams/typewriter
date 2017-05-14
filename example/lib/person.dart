import 'package:typewriter/annotations.dart';

@deriveJson()
class Person {
  String name;
  int age;
  double money;
  @jsonProperty('is_alive')
  bool isAlive;
  Symbol opaque;
}
