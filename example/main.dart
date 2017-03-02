library typewriter.example;

import 'lib/codecs/codecs.dart';
import 'lib/person.dart';
import 'package:xml/xml.dart';

void main() {
  final item = new Item()
    ..description = 'This is an item'
    ..id = 2
    ..name = 'Foo'
    ..why = new RegExp('/w+')
    ..other = 'Ignore me';

  print(itemXmlCodec.encode(item));
}
