library typewriter.example;

import 'lib/codecs/codecs.dart';
import 'lib/person.dart';
import 'package:xml/xml.dart';

void main() {
  var raw =
      '<Item>'
      '  <name>Jonah</name>'
      '  <id>1</id>'
      '  <description>This is a test</description>'
      '  <why>why</why>'
      '</Item>';
  var item = new ItemCodec().decode(parse(raw).firstChild);
  print(item);
}