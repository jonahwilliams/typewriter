import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:test/test.dart';
import 'package:typewriter/metadata/metadata.dart';
import 'package:mockito/mockito.dart';

import 'package:typewriter/metadata/xml_description.dart';

void main() {
  final stringType = new MockType();
  final intType = new MockType();
  final registry = <DartType, Metadata>{
    stringType: new Metadata.scalar('String',
        encoder: (arg) => arg, decoder: (arg) => arg),
    intType: new Metadata.scalar('int',
        encoder: (arg) => arg.invoke('toString', const []),
        decoder: (arg) => reference('int').invoke('parse', [arg, literal(10)]))
  };

  final description = new XmlDescription('People', 'People', [
    new XmlElementDescription('name', 'name', false, stringType, const []),
    new XmlElementDescription('id', 'id', false, intType, const []),
  ]);

  group('Xml encoder', () {
    test('encodes a class', () {
      final encoder =
          prettyToSource(description.buildEncoder(registry).buildClass());
      final expected =
          'class _PeopleEncoder extends Converter<People, XmlNode> {\n'
          '  _PeopleEncoder();\n'
          '\n'
          '  XmlNode convert(People input) {\n'
          '    var builder = new XmlBuilder();\n'
          '    builder.element(\'People\', nest: () {\n'
          '      builder.element(\'name\', input.name);\n'
          '      builder.element(\'id\', input.id.toString());\n'
          '    });\n'
          '    return builder.build();\n'
          '  }\n'
          '}\n';

      expect(encoder, expected);
    });
  });

  group('Xml decoder', () {
    test('decodes a class', () {
      final decoder =
          prettyToSource(description.buildDecoder(registry).buildClass());
      final expected =
          'class _PeopleDecoder extends Converter<XmlNode, People> {\n'
          '  _PeopleDecoder();\n'
          '\n'
          '  People convert(XmlNode input) {\n'
          '    var output = new People();\n'
          '    output.name = input.findElements(\'name\').first;\n'
          '    output.id = int.parse(input.findElements(\'id\').first, 10);\n'
          '    return output;\n'
          '  }\n'
          '}\n';

      expect(decoder, expected);
    });
  });

  group('Xml Codec', () {
    test('creates a class which exposes the encoder and decoder', () {
      final codec =
          prettyToSource(description.buildCodec(registry).buildClass());
      final expected = 'class PeopleCodec extends Codec<XmlNode, People> {\n'
          '  PeopleCodec();\n'
          '\n'
          '  Converter<People, XmlNode> get encoder => new _PeopleEncoder();\n'
          '\n'
          '  Converter<XmlNode, People> get decoder => new _PeopleDecoder();\n'
          '}\n';

      expect(codec, expected);
    });
  });
}

class MockType extends Mock implements DartType {}