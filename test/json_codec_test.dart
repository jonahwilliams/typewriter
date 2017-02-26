import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:test/test.dart';
import 'package:typewriter/metadata/metadata.dart';
import 'package:mockito/mockito.dart';

import 'package:typewriter/metadata/json_description.dart';

void main() {
  final stringType = new MockType();
  final intType = new MockType();
  final registry = <DartType, Metadata>{
    stringType: new Metadata.scalar('String',
        encoder: (arg) => arg, decoder: (arg) => arg),
    intType:
        new Metadata.scalar('int', encoder: (arg) => arg, decoder: (arg) => arg)
  };

  group('Json encoder', () {
    test('encodes a class', () {
      final description = new JsonDescription('People', [
        new JsonFieldDescription('name', stringType),
        new JsonFieldDescription('id', intType),
      ]);
      final encoder =
          prettyToSource(description.buildEncoder(registry).buildClass());
      final expected =
          'class _PeopleEncoder extends Converter<People, Object> {\n'
          '  _PeopleEncoder();\n'
          '\n'
          '  Object convert(People input) {\n'
          '    var output = <String, dynamic>{};\n'
          '    output[\'name\'] = input.name;\n'
          '    output[\'id\'] = input.id;\n'
          '    return output;\n'
          '  }\n'
          '}\n';

      expect(encoder, expected);
    });

    test('encodes a class with repeated fields', () {
      final description = new JsonDescription('People', [
        new JsonFieldDescription('name', stringType),
        new JsonFieldDescription('values', intType, repeated: true),
      ]);
      final encoder =
          prettyToSource(description.buildEncoder(registry).buildClass());
      final expected =
          'class _PeopleEncoder extends Converter<People, Object> {\n'
          '  _PeopleEncoder();\n'
          '\n'
          '  Object convert(People input) {\n'
          '    var output = <String, dynamic>{};\n'
          '    output[\'name\'] = input.name;\n'
          '    output[\'values\'] = input.values.map((x) => x).toList();\n'
          '    return output;\n'
          '  }\n'
          '}\n'
          '';

      expect(encoder, expected);
    });
  });

  group('Json decoder', () {
    test('decodes a class', () {
      final description = new JsonDescription('People', [
        new JsonFieldDescription('name', stringType),
        new JsonFieldDescription('id', intType),
      ]);
      final decoder =
          prettyToSource(description.buildDecoder(registry).buildClass());
      final expected =
          'class _PeopleDecoder extends Converter<Object, People> {\n'
          '  _PeopleDecoder();\n'
          '\n'
          '  People convert(Object rawInput) {\n'
          '    var input = rawInput as Map<String, dynamic>;\n'
          '    var output = new People();\n'
          '    output.name = input[\'name\'];\n'
          '    output.id = input[\'id\'];\n'
          '    return output;\n'
          '  }\n'
          '}\n';

      expect(decoder, expected);
    });
  });

  group('Json Codec', () {
    test('creates a class which exposes the encoder and decoder', () {
      final description = new JsonDescription('People', [
        new JsonFieldDescription('name', stringType),
        new JsonFieldDescription('id', intType),
      ]);
      final codec =
          prettyToSource(description.buildCodec(registry).buildClass());
      final expected = 'class PeopleCodec extends Codec<Object, People> {\n'
          '  PeopleCodec();\n'
          '\n'
          '  Converter<People, Object> get encoder => new _PeopleEncoder();\n'
          '\n'
          '  Converter<Object, People> get decoder => new _PeopleDecoder();\n'
          '}\n';

      expect(codec, expected);
    });
  });
}

class MockType extends Mock implements DartType {}
