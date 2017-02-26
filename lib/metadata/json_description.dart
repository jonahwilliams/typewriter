import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

import 'metadata.dart';

/// A description and builder for JSON codecs.
class JsonDescription implements BuildsCodec {
  static final _jsonType = reference('Object');

  final String name;
  final List<JsonFieldDescription> fields;

  const JsonDescription(this.name, this.fields);

  @override
  ClassBuilder buildEncoder(Map<DartType, Metadata> registry) {
    final type = new TypeBuilder(name);

    return new ClassBuilder('_${name}Encoder',
        asExtends:
            new TypeBuilder('Converter', genericTypes: [type, _jsonType]))
      ..addConstructor(new ConstructorBuilder())
      ..addMethod(new MethodBuilder('convert', returnType: _jsonType)
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

    return new ClassBuilder('_${name}Decoder',
        asExtends:
            new TypeBuilder('Converter', genericTypes: [_jsonType, type]))
      ..addConstructor(new ConstructorBuilder())
      ..addMethod(new MethodBuilder('convert', returnType: type)
        ..addPositional(new ParameterBuilder('rawInput', type: _jsonType))
        ..addStatement(reference('rawInput')
            .castAs(new TypeBuilder('Map', genericTypes: [
              new TypeBuilder('String'),
              new TypeBuilder('dynamic')
            ]))
            .asVar('input'))
        ..addStatement(reference(name).newInstance([]).asVar('output'))
        ..addStatements(fields.map((field) => field.buildDecoder(registry)))
        ..addStatement(reference('output').asReturn()));
  }

  @override
  ClassBuilder buildCodec(Map<DartType, Metadata> registry) {
    final type = new TypeBuilder(name);

    return new ClassBuilder('${name}Codec',
        asExtends: new TypeBuilder('Codec',
            genericTypes: [_jsonType, type], importFrom: 'dart:convert'))
      ..addConstructor(new ConstructorBuilder())
      ..addMethod(new MethodBuilder.getter('encoder',
          returns: reference('_${name}Encoder').newInstance(const []),
          returnType:
              new TypeBuilder('Converter', genericTypes: [type, _jsonType])))
      ..addMethod(new MethodBuilder.getter('decoder',
          returns: reference('_${name}Decoder').newInstance(const []),
          returnType:
              new TypeBuilder('Converter', genericTypes: [_jsonType, type])));
  }
}

class JsonFieldDescription {
  final String key;
  final String field;
  final bool repeated;
  final DartType type;

  const JsonFieldDescription(this.field, this.type,
      {this.repeated = false, String key})
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

    final encode = registry[type].encoder(reference('input').property(field));
    return encode.asAssign(reference('output')[literal(key)]);
  }

  StatementBuilder buildDecoder(Map<DartType, Metadata> registry) {
    final decode = registry[type].decoder(reference('input')[literal(key)]);
    return decode.asAssign(reference('output').property(field));
  }

  @override
  bool operator ==(Object other) =>
      other is JsonFieldDescription &&
      other.key == key &&
      other.field == field &&
      other.repeated == repeated &&
      other.type == type;

  @override
  String toString()
    => '<$key/$field repeated:$repeated type:${type.displayName}>';
}
