import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import 'metadata.dart';

const _listEquality = const ListEquality();

class DescriptionXml implements BuildsCodec {
  static final _xmlType =
      new TypeBuilder('XmlElement', importFrom: 'package:xml/xml.dart');
  static final _builder = reference('builder');
  static final _output = reference('output');

  final String name;
  final String key;
  final List<DescriptionXmlElement> elements;
  final List<DescriptionXmlAttribute> attributes;

  const DescriptionXml(this.name,
      {String key, this.elements: const [], this.attributes: const []})
      : this.key = key ?? name;

  @override
  ClassBuilder buildEncoder(Map<DartType, Metadata> registry) {
    final type = new TypeBuilder(name);

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
            reference('XmlElement').newInstance([
              reference('XmlName').newInstance([literal(key)]),
              list(attributes.map((attr) => attr.buildEncoder(registry))),
              list(elements.map((el) => el.buildEncoder(registry))),
            ]).asReturn()));
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
        ..addStatement(reference(name).newInstance(const []).asFinal('output'))
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

  @override
  bool operator ==(Object other) =>
      other is DescriptionXml &&
      other.name == name &&
      other.key == key &&
      _listEquality.equals(other.attributes, attributes) &&
      _listEquality.equals(other.elements, elements);
}

class DescriptionXmlElement {
  static final _builder = reference('builder');
  static final _output = reference('output');
  static final _input = reference('input');

  final String key;
  final String name;
  final bool repeated;
  final String repeatedKey;
  final DartType type;
  final List<DescriptionXmlAttribute> attributes;

  const DescriptionXmlElement(this.name, this.type,
      {String key,
      this.repeated: false,
      this.attributes: const [],
      this.repeatedKey: 'item'})
      : this.key = key ?? name;


  ExpressionBuilder buildEncoder(Map<DartType, Metadata> registry) {
    final encode = registry[type].encoder(_input.property(name));
    final attrs = list([], asConst: true);

    return reference('XmlElement').newInstance([
      reference('XmlName').newInstance([literal(key)]),
      attrs,
      list([
        reference('XmlText').newInstance([encode])
      ])
    ]);
  }

  StatementBuilder buildDecoder(Map<DartType, Metadata> registry) {
    final decode = registry[type].decoder(reference('input')
        .invoke('findElements', [literal(key)])
        .property('first')
        .property('text'));

    return decode.asAssign(_output.property(name));
  }

  @override
  bool operator ==(Object other) =>
      other is DescriptionXmlElement &&
      other.name == name &&
      other.key == key &&
      other.repeated == repeated &&
      other.repeatedKey == repeatedKey &&
      other.type == type &&
      _listEquality.equals(other.attributes, attributes);

  @override
  String toString() => '<$this $name:$key $type repeated: '
      '$repeated [$attributes]>';
}

XmlAttribute atr;
/// A description of a codec to build an XmlAttribute from a class field.
class DescriptionXmlAttribute {
  final String key;
  final String name;
  final DartType type;

  const DescriptionXmlAttribute(this.name, this.type, {String key})
      : this.key = key ?? name;

  ExpressionBuilder buildEncoder(Map<DartType, Metadata> registry) {
    final encode = registry[type].encoder(reference('input').property(name));
    return reference('XmlAttribute').newInstance([
      reference('XmlName').newInstance([literal(key)]),
      encode,
    ]);
  }

  ExpressionBuilder buildDecoder(Map<DartType, Metadata> registry) {}

  @override
  bool operator ==(Object other) =>
      other is DescriptionXmlAttribute &&
      other.name == name &&
      other.key == key &&
      other.type == type;
}
