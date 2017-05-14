import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

abstract class BuildsCodec {
  ClassBuilder buildCodec(Map<DartType, Metadata> registry);

  ClassBuilder buildDecoder(Map<DartType, Metadata> registry);

  ClassBuilder buildEncoder(Map<DartType, Metadata> registry);
}

typedef ExpressionBuilder ExpressionBuilderBuilder(
    ExpressionBuilder expressionBuilder);

/// Builds an initial map of serialization information for xml
///
/// Contains the information that lets typewriter know it has to call
/// `int.parse` or `x.toIso8601String`.
Map<DartType, Metadata> buildXmlRegistry(LibraryElement coreLibrary) {
  var provider = coreLibrary.context.typeProvider;
  var datetimeType = coreLibrary.getType('DateTime').type;
  var regexpType = coreLibrary.getType('RegExp').type;

  return {
    provider.boolType: new Metadata.scalar(
      'bool',
      encoder: (arg) => arg.invoke('toString', const []),
      decoder: (arg) => arg.equals(literal('true')),
    ),
    provider.stringType: new Metadata.scalar(
      'String',
      encoder: (arg) => arg,
      decoder: (arg) => arg,
    ),
    provider.intType: new Metadata.scalar(
      'int',
      encoder: (arg) => arg.invoke('toString', const []),
      decoder: (arg) => reference('int').invoke('parse', [arg]),
    ),
    provider.doubleType: new Metadata.scalar(
      'double',
      encoder: (arg) => arg.invoke('toString', const []),
      decoder: (arg) => reference('double').invoke('parse', [arg, literal(10)]),
    ),
    provider.symbolType: new Metadata.scalar(
      'Symbol',
      encoder: (arg) => arg.invoke('toString', const []),
      decoder: (arg) => reference('Symbol').newInstance([arg]),
    ),
    provider.nullType: new Metadata.scalar('Null',
        encoder: (arg) => literal('null'), decoder: (arg) => literal(null)),
    regexpType: new Metadata.scalar(
      'RegExp',
      encoder: (arg) => arg.invoke('toString', const []),
      decoder: (arg) => reference('RegExp').newInstance([arg]),
    ),
    datetimeType: new Metadata.scalar(
      'DateTime',
      encoder: (arg) => arg.invoke('toIso8601String', const []),
      decoder: (arg) => reference('DateTime').invoke('parse', [arg]),
    ),
  };
}

/// Builds an initial map of serialization information for Json.
///
/// Contains the information that lets typewriter know it has to call
/// `int.parse` or `x.toIso8601String`.
Map<DartType, Metadata> buildJsonRegistry(LibraryElement coreLibrary) {
  final provider = coreLibrary.context.typeProvider;
  final datetimeType = coreLibrary.getType('DateTime').type;
  final regexpType = coreLibrary.getType('RegExp').type;

  return {
    provider.boolType: new Metadata.scalar(
      'bool',
      encoder: (arg) => arg,
      decoder: (arg) => arg,
    ),
    provider.stringType: new Metadata.scalar(
      'String',
      encoder: (arg) => arg,
      decoder: (arg) => arg,
    ),
    provider.intType: new Metadata.scalar(
      'int',
      encoder: (arg) => arg,
      decoder: (arg) => arg,
    ),
    provider.doubleType: new Metadata.scalar(
      'double',
      encoder: (arg) => arg,
      decoder: (arg) => arg,
    ),
    provider.symbolType: new Metadata.scalar(
      'Symbol',
      encoder: (arg) => arg.invoke('toString', const []),
      decoder: (arg) => reference('Symbol').newInstance([arg]),
    ),
    provider.nullType: new Metadata.scalar(
      'Null',
      encoder: (arg) => literal('null'),
      decoder: (arg) => literal(null),
    ),
    regexpType: new Metadata.scalar(
      'RegExp',
      encoder: (arg) => arg.invoke('toString', const []),
      decoder: (arg) => reference('RegExp').newInstance([arg]),
    ),
    datetimeType: new Metadata.scalar(
      'DateTime',
      encoder: (arg) => arg.invoke('toIso8601String', const []),
      decoder: (arg) => reference('DateTime').invoke('parse', [arg]),
    ),
  };
}

/// Metadata carries encode and decode expressions.
///
/// It is used to nest converters in each other and handle platform specific
/// serialization logic.
class Metadata {
  final String name;
  final ExpressionBuilderBuilder encoder;
  final ExpressionBuilderBuilder decoder;

  /// Creates metadata for a type like String or int which represents a
  /// singular value.
  factory Metadata.scalar(
    String name, {
    ExpressionBuilderBuilder encoder,
    ExpressionBuilderBuilder decoder,
  }) {
    return new Metadata._(name, encoder, decoder);
  }

  /// Creates metadata for a class which is composed of several fields.
  factory Metadata.composite(String name) {
    var encoder = (ExpressionBuilder arg) {
      return reference('_${name}Encoder')
          .newInstance(const []).invoke('convert', [arg]);
    };
    var decoder = (ExpressionBuilder arg) {
      return reference('_${name}Decoder')
          .newInstance(const []).invoke('convert', [arg]);
    };
    return new Metadata._(name, encoder, decoder);
  }

  const Metadata._(this.name, this.encoder, this.decoder);
}

/// A description and builder for JSON codecs.
class JsonDescription implements BuildsCodec {
  final String name;
  final List<JsonFieldDescription> fields;

  const JsonDescription(this.name, this.fields);

  @override
  ClassBuilder buildEncoder(Map<DartType, Metadata> registry) {
    var type = new TypeBuilder(name);
    var jsonType = new TypeBuilder('Map',
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
    var type = new TypeBuilder(name);
    var jsonType = new TypeBuilder('Map',
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
    var type = new TypeBuilder(name);
    var jsonType = new TypeBuilder(
      'Map',
      genericTypes: [new TypeBuilder('String'), new TypeBuilder('dynamic')],
    );

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

class JsonFieldDescription {
  final String key;
  final String field;
  final bool repeated;
  final DartType type;

  const JsonFieldDescription(this.field, this.type,
      {this.repeated: false, String key})
      : this.key = key ?? field;

  StatementBuilder buildEncoder(Map<DartType, Metadata> registry) {
    if (repeated) {
      var encoder = registry[type].encoder;
      var converter =
          new MethodBuilder.closure(returns: encoder(reference('x')))
            ..addPositional(new ParameterBuilder('x'));

      return reference('input')
          .property(field)
          .invoke('map', [converter]).invoke(
              'toList', const []).asAssign(reference('output')[literal(key)]);
    }

    var encode = registry[type].encoder(reference('input').property(field));
    return encode.asAssign(reference('output')[literal(key)]);
  }

  StatementBuilder buildDecoder(Map<DartType, Metadata> registry) {
    var decode = registry[type].decoder(reference('input')[literal(key)]);
    return decode.asAssign(reference('output').property(field));
  }
}

class XmlDescription implements BuildsCodec {
  static final _xmlType =
      new TypeBuilder('XmlElement', importFrom: 'package:xml/xml.dart');
  static final _builder = reference('builder');
  static final _output = reference('output');
  final String name, key;
  final List<XmlElementDescription> elements;
  final List<XmlAttributeDescription> attributes;

  const XmlDescription(this.name, this.key, this.elements,
      [this.attributes = const []]);

  @override
  ClassBuilder buildEncoder(Map<DartType, Metadata> registry) {
    var topLevelNest = new MethodBuilder.closure();
    var type = new TypeBuilder(name);

    for (var element in elements) {
      topLevelNest.addStatement(element.buildEncoder(registry));
    }
    for (var attribute in attributes) {
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
    var topLevelStatements = <StatementBuilder>[];
    var type = new TypeBuilder(name);

    for (var element in elements) {
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
    var type = new TypeBuilder(name);

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

  final String key, field, repeatedKey;
  final bool repeated;
  final DartType type;
  final List<XmlAttributeDescription> attributes;

  const XmlElementDescription(
      this.key, this.field, this.repeated, this.type, this.attributes,
      [this.repeatedKey = 'item']);

  StatementBuilder buildEncoder(Map<DartType, Metadata> registry) {
    var encode = registry[type].encoder(_input.property(field));

    return _builder.invoke('element', [
      literal(key),
    ], namedArguments: {
      'nest': new MethodBuilder.closure()
        ..addStatement(_builder.invoke('text', [encode]))
        ..addStatements(
          attributes.map((x) => x.buildEncoder(registry)),
        )
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
  final String key, value;
  final DartType type;

  const XmlAttributeDescription(this.key, this.value, this.type);

  ExpressionBuilder buildEncoder(Map<DartType, Metadata> registry) {
    return _builder.invoke('attribute', [literal(key), literal(value)]);
  }
}
