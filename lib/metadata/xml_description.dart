import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

import 'metadata.dart';

class XmlDescription implements BuildsCodec {
  static final _xmlType =
      new TypeBuilder('XmlNode', importFrom: 'package:xml/xml.dart');
  static final _builder = reference('builder');
  static final _output = reference('output');

  final String name;
  final String key;
  final List<XmlElementDescription> elements;
  final List<XmlAttributeDescription> attributes;

  const XmlDescription(this.name, this.key, this.elements,
      [this.attributes = const []]);

  @override
  ClassBuilder buildEncoder(Map<DartType, Metadata> registry) {
    final topLevelNest = new MethodBuilder.closure();
    final type = new TypeBuilder(name);

    for (final element in elements) {
      topLevelNest.addStatement(element.buildEncoder(registry));
    }
    for (final attribute in attributes) {
      topLevelNest.addStatement(_builder
          .invoke('attribute', [literal(attribute.key), literal('bar')]));
    }

    return new ClassBuilder('_${name}Encoder',
        asExtends: new TypeBuilder('Converter',
            genericTypes: [
              type,
              _xmlType,
            ],
            importFrom: 'package:convert'))
      ..addConstructor(new ConstructorBuilder())
      ..addMethod(new MethodBuilder('convert', returnType: _xmlType)
        ..addPositional(new ParameterBuilder('input', type: type))
        ..addStatement(
            reference('XmlBuilder').newInstance(const []).asVar('builder'))
        ..addStatement(_builder.invoke('element', [literal(key)],
            namedArguments: {'nest': topLevelNest}))
        ..addStatement(_builder.invoke('build', const []).asReturn()));
  }

  @override
  ClassBuilder buildDecoder(Map<DartType, Metadata> registry) {
    final topLevelStatements = <StatementBuilder>[];
    final type = new TypeBuilder(name);

    for (final element in elements) {
      topLevelStatements.add(element.buildDecoder(registry));
    }

    return new ClassBuilder('_${name}Decoder',
        asExtends: new TypeBuilder('Converter',
            genericTypes: [
              _xmlType,
              type,
            ],
            importFrom: 'dart:convert'))
      ..addConstructor(new ConstructorBuilder())
      ..addMethod(new MethodBuilder('convert', returnType: type)
        ..addPositional(new ParameterBuilder('input', type: _xmlType))
        ..addStatement(reference(name).newInstance(const []).asVar('output'))
        ..addStatements(topLevelStatements)
        ..addStatement(_output.asReturn()));
  }

  @override
  ClassBuilder buildCodec(Map<DartType, Metadata> registry) {
    final type = new TypeBuilder(name);

    return new ClassBuilder('${name}Codec',
        asExtends: new TypeBuilder('Codec',
            genericTypes: [type, _xmlType], importFrom: 'dart:convert'))
      ..addConstructor(new ConstructorBuilder())
      ..addMethod(new MethodBuilder.getter('encoder',
          returns: reference('_${name}Encoder').newInstance(const []),
          returnType:
              new TypeBuilder('Converter', genericTypes: [type, _xmlType])))
      ..addMethod(new MethodBuilder.getter('decoder',
          returns: reference('_${name}Decoder').newInstance(const []),
          returnType:
              new TypeBuilder('Converter', genericTypes: [_xmlType, type])));
  }
}

class XmlElementDescription {
  static final _builder = reference('builder');
  static final _output = reference('output');
  static final _input = reference('input');

  final String key;
  final String field;
  final bool repeated;
  final String repeatedKey;
  final DartType type;
  final List<XmlAttributeDescription> attributes;

  const XmlElementDescription(
      this.key, this.field, this.repeated, this.type, this.attributes,
      [this.repeatedKey = 'item']);

  StatementBuilder buildEncoder(Map<DartType, Metadata> registry) {
    final encode = registry[type].encoder(_input.property(field));

    return _builder.invoke('element', [
      literal(key),
    ], namedArguments: {
      'nest': new MethodBuilder.closure()
        ..addStatement(_builder.invoke('text', [encode]))
        ..addStatements(attributes.map((x) => x.buildEncoder(registry)))
    });
  }

  StatementBuilder buildDecoder(Map<DartType, Metadata> registry) {
    final decode = registry[type].decoder(reference('input')
        .invoke('findElements', [literal(key)])
        .property('first')
        .property('text'));

    return decode.asAssign(_output.property(field));
  }
}

class XmlAttributeDescription {
  static final _builder = reference('builder');
  final String key;
  final DartType type;
  final String value;

  const XmlAttributeDescription(this.key, this.value, this.type);

  ExpressionBuilder buildEncoder(Map<DartType, Metadata> registry) {
    return _builder.invoke('attribute', [literal(key), literal(value)]);
  }
}
