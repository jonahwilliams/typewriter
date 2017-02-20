library typewriter.example;

import 'lib/codecs/codecs.dart';
import 'lib/person.dart';
import 'lib/dog.dart';
import 'lib/item.dart';

void main() {
  final person = new Person()
    ..name = 'Jonah'
    ..age = 25
    ..birthday = new DateTime.now()
    ..dog = (new Dog()
      ..name = 'Ruffles'
      ..age = 1.0
      ..birthday = new DateTime(2016))
    ..item = (new Item()
      ..description = "This is a test item"
      ..id = 2);

  print(personJsonCodec.encode(person));
  print(personJsonCodec
      .encode(personJsonCodec.decode(personJsonCodec.encode(person))));
}
