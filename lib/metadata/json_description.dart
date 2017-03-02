import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';

import 'metadata.dart';

/// A description and builder for JSON codecs.
class DescriptionJson implements BuildsCodec {
  @override
  final String name;
  final List<DescriptionJsonField> fields;

  const DescriptionJson(this.name, this.fields);

  @override
  ClassBuilder buildEncoder(Map<DartType, Metadata> registry) {
    final type = new TypeBuilder(name);
    final jsonType = new TypeBuilder('Map',
        genericTypes: [new TypeBuilder('String'), new TypeBuilder('dynamic')]);

    return new ClassBuilder('_${name}Encoder',
        asExtends: new TypeBuilder('Converter', genericTypes: [
          type,
          jsonType,
        ]))
      ..addConstructor(new ConstructorBuilder())
      ..addMethod(new MethodBuilder('convert', returnType: jsonType)
        ..addPositional(new ParameterBuilder('input', type: type))
        ..addStatement(map({},
                keyType: new TypeBuilder('String'),
                valueType: new TypeBuilder('dynamic'))
            .asVar('output'))
        ..addStatements(fields.map((field) => field.buildEncoder(registry)))
        ..addStatement(reference('output').asReturn()));
  }

  @override
  ClassBuilder buildDecoder(Map<DartType, Metadata> registry) {
    final type = new TypeBuilder(name);
    final jsonType = new TypeBuilder('Map',
        genericTypes: [new TypeBuilder('String'), new TypeBuilder('dynamic')]);

    return new ClassBuilder('_${name}Decoder',
        asExtends: new TypeBuilder('Converter', genericTypes: [jsonType, type]))
      ..addConstructor(new ConstructorBuilder())
      ..addMethod(new MethodBuilder('convert', returnType: type)
        ..addPositional(new ParameterBuilder('input', type: jsonType))
        ..addStatement(reference(name).newInstance([]).asVar('output'))
        ..addStatements(fields.map((field) => field.buildDecoder(registry)))
        ..addStatement(reference('output').asReturn()));
  }

  @override
  ClassBuilder buildCodec(Map<DartType, Metadata> registry) {
    final type = new TypeBuilder(name);
    final jsonType = new TypeBuilder('Map',
        genericTypes: [new TypeBuilder('String'), new TypeBuilder('dynamic')]);

    return new ClassBuilder('${name}Codec',
        asExtends: new TypeBuilder('Codec',
            genericTypes: [type, jsonType], importFrom: 'dart:convert'))
      ..addConstructor(new ConstructorBuilder())
      ..addMethod(new MethodBuilder.getter('encoder',
          returns: reference('_${name}Encoder').newInstance(const []),
          returnType:
              new TypeBuilder('Converter', genericTypes: [type, jsonType])))
      ..addMethod(new MethodBuilder.getter('decoder',
          returns: reference('_${name}Decoder').newInstance(const []),
          returnType:
              new TypeBuilder('Converter', genericTypes: [jsonType, type])));
  }
}

class DescriptionJsonField {
  final String key;
  final String field;
  final bool repeated;
  final DartType type;

  const DescriptionJsonField(this.field, this.type,
      {this.repeated: false, String key})
      : this.key = key ?? field;

  StatementBuilder buildEncoder(Map<DartType, Metadata> registry) {
    if (repeated) {
      final encoder = registry[type].encoder;
      final converter =
          new MethodBuilder.closure(returns: encoder(reference('x')))
            ..addPositional(new ParameterBuilder('x'));

      return reference('input')
          .property(field)
          .invoke('map', [converter]).invoke(
              'toList', const []).asAssign(reference('output')[literal(key)]);
    }
    final encode = registry[type]?.encoder(reference('input').property(field));
    if (encode == null) {
      throw new Exception('Could not find encoder for $type');
    }
    return encode.asAssign(reference('output')[literal(key)]);
  }

  StatementBuilder buildDecoder(Map<DartType, Metadata> registry) {
    final decode = registry[type].decoder(reference('input')[literal(key)]);
    return decode.asAssign(reference('output').property(field));
  }

  @override
  bool operator ==(Object other) =>
      other is DescriptionJsonField &&
      other.key == key &&
      other.field == field &&
      other.repeated == repeated &&
      other.type == type;

  @override
  String toString() =>
      '<$key/$field repeated:$repeated type:${type.displayName}>';
}
