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
  final provider = coreLibrary.context.typeProvider;
  final datetimeType = coreLibrary.getType('DateTime').type;
  final regexpType = coreLibrary.getType('RegExp').type;

  return {
    provider.boolType: new Metadata.scalar('bool',
        encoder: (arg) => arg.invoke('toString', const []),
        decoder: (arg) => arg.equals(literal('true'))),
    provider.stringType: new Metadata.scalar('String',
        encoder: (arg) => arg, decoder: (arg) => arg),
    provider.intType: new Metadata.scalar('int',
        encoder: (arg) => arg.invoke('toString', const []),
        decoder: (arg) => reference('int').invoke('parse', [arg, literal(10)])),
    provider.doubleType: new Metadata.scalar('double',
        encoder: (arg) => arg.invoke('toString', const []),
        decoder: (arg) =>
            reference('double').invoke('parse', [arg, literal(10)])),
    provider.symbolType: new Metadata.scalar('Symbol',
        encoder: (arg) => arg.invoke('toString', const []),
        decoder: (arg) => reference('Symbol').newInstance([arg])),
    provider.nullType: new Metadata.scalar('Null',
        encoder: (arg) => literal('null'), decoder: (arg) => literal(null)),
    regexpType: new Metadata.scalar('RegExp',
        encoder: (arg) => arg.invoke('toString', const []),
        decoder: (arg) => reference('RegExp').newInstance([arg])),
    datetimeType: new Metadata.scalar('DateTime',
        encoder: (arg) => arg.invoke('toIso8601String', const []),
        decoder: (arg) => reference('DateTime').invoke('parse', [arg])),
  };
}

/// Builds an initial map of serialization information for json
///
/// Contains the information that lets typewriter know it has to call
/// `int.parse` or `x.toIso8601String`.
Map<DartType, Metadata> buildJsonRegistry(LibraryElement coreLibrary) {
  final provider = coreLibrary.context.typeProvider;
  final datetimeType = coreLibrary.getType('DateTime').type;
  final regexpType = coreLibrary.getType('RegExp').type;

  return {
    provider.boolType: new Metadata.scalar('bool',
        encoder: (arg) => arg, decoder: (arg) => arg),
    provider.stringType: new Metadata.scalar('String',
        encoder: (arg) => arg, decoder: (arg) => arg),
    provider.intType: new Metadata.scalar('int',
        encoder: (arg) => arg, decoder: (arg) => arg),
    provider.doubleType: new Metadata.scalar('double',
        encoder: (arg) => arg, decoder: (arg) => arg),
    provider.symbolType: new Metadata.scalar('Symbol',
        encoder: (arg) => arg.invoke('toString', const []),
        decoder: (arg) => reference('Symbol').newInstance([arg])),
    provider.nullType: new Metadata.scalar('Null',
        encoder: (arg) => literal('null'), decoder: (arg) => literal(null)),
    regexpType: new Metadata.scalar('RegExp',
        encoder: (arg) => arg.invoke('toString', const []),
        decoder: (arg) => reference('RegExp').newInstance([arg])),
    datetimeType: new Metadata.scalar('DateTime',
        encoder: (arg) => arg.invoke('toIso8601String', const []),
        decoder: (arg) => reference('DateTime').invoke('parse', [arg])),
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

  /// Creates metadata for a type like String or int which represents a singular
  /// value.
  factory Metadata.scalar(String name,
      {ExpressionBuilderBuilder encoder, ExpressionBuilderBuilder decoder}) {
    return new Metadata._(name, encoder, decoder);
  }

  /// Creates metadata for a class which is composed of several fields.
  factory Metadata.composite(String name) {
    final encoder = (ExpressionBuilder arg) {
      return reference('_${name}Encoder')
          .newInstance(const []).invoke('convert', [arg]);
    };
    final decoder = (ExpressionBuilder arg) {
      return reference('_${name}Decoder')
          .newInstance(const []).invoke('convert', [arg]);
    };
    return new Metadata._(name, encoder, decoder);
  }

  const Metadata._(this.name, this.encoder, this.decoder);
}
