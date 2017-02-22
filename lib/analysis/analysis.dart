import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/resolver.dart';
import 'package:resolver/src/analyzer.dart';
import 'dart:core';

typedef String Writer(String input);

abstract class TypeMetadata {
  String get displayName;

  bool get isScalar;
}

class ScalarTypeMetadata implements TypeMetadata {
  final Writer encodeString;
  final Writer decodeString;
  final DartType _type;

  const ScalarTypeMetadata(this._type, this.encodeString, this.decodeString);

  String get displayName => _type.displayName;

  bool get isScalar => true;
}

class SystemTypeProvider {
  final DartType ignore;
  final DartType jsonKey;
  final DartType json;
  final DartType jsonEncoder;
  final DartType jsonDecoder;

  factory SystemTypeProvider(LibraryElement library) {
    return new SystemTypeProvider._(
        library.getType('Ignore').type,
        library.getType('JsonKey').type,
        library.getType('Json').type,
        library.getType('JsonEncoder').type,
        library.getType('JsonDecoder').type);
  }

  SystemTypeProvider._(
      this.ignore, this.jsonKey, this.json, this.jsonEncoder, this.jsonDecoder);
}

class CompositeTypeMetadata implements TypeMetadata {
  final ClassElement element;
  final DartType _type;
  const CompositeTypeMetadata(this._type, this.element);

  String get displayName => _type.displayName;

  bool get isScalar => false;
}

class MetadataRegistry {
  static String _identity(String input) => input;
  Map<DartType, TypeMetadata> metadata;
  Set<DartType> missing = new Set();

  MetadataRegistry();

  initialize(AnalysisContext context, LibraryElement coreLibrary) {
    final provider = context.typeProvider;
    final dateTimeType = coreLibrary.getType('DateTime').type;
    final regexType = coreLibrary.getType('RegExp').type;
    final symbolType = coreLibrary.getType('Symbol').type;

    metadata = {
      provider.boolType:
          new ScalarTypeMetadata(provider.boolType, _identity, _identity),
      provider.doubleType:
          new ScalarTypeMetadata(provider.doubleType, _identity, _identity),
      provider.intType:
          new ScalarTypeMetadata(provider.intType, _identity, _identity),
      provider.stringType:
          new ScalarTypeMetadata(provider.stringType, _identity, _identity),
      provider.nullType:
          new ScalarTypeMetadata(provider.nullType, _identity, (x) => 'null'),
      dateTimeType: new ScalarTypeMetadata(dateTimeType,
          (x) => '${x}.toIso8601String()', (x) => 'DateTime.parse(${x})'),
      regexType: new ScalarTypeMetadata(
          regexType, (x) => '${x}.pattern', (x) => 'new RegExp(${x})'),
      symbolType: new ScalarTypeMetadata(
          symbolType, (x) => '${x}.toString()', (x) => 'new Symbol(${x})')
    };
  }
}

abstract class CodecBuilder {
  factory CodecBuilder.Json(MetadataRegistry registry, DartType type) {
    return new JsonCodecBuilder(registry, type);
  }

  void addField(
      String name, DartType type, bool isRepeated, String key, int position);

  String build();
}

class JsonCodecBuilder implements CodecBuilder {
  MetadataRegistry _registry;

  String _name;
  String _codec;

  final StringBuffer _encoder = new StringBuffer();
  final StringBuffer _decoder = new StringBuffer();

  JsonCodecBuilder(this._registry, DartType type) {
    _name = type.displayName;
    _codec = '''
    class ${_name}Codec extends Codec<${_name}, Object> {
      const ${_name}Codec();

      @override
      Converter<Object, ${_name}> get decoder => const ${_name}Decoder();

      @override
      Converter<${_name}, Object> get encoder => const ${_name}Encoder();
    }
    ''';
    _decoder.write('''
      class ${_name}Decoder extends Converter<Object, ${_name}> {

      const ${_name}Decoder();

      @override
      ${_name} convert(Object raw) {
        var input = raw as Map<String, dynamic>;
        var output = new ${_name}();
    ''');
    _encoder.write('''
      class ${_name}Encoder extends Converter<${_name}, Object> {

      const ${_name}Encoder();

      @override
      Object convert(${_name} input) {
        var output = <String, dynamic>{};
    ''');
  }

  @override
  void addField(
      String name, DartType type, bool isRepeated, String key, int _) {
    TypeMetadata metadataRaw = _registry.metadata[type];
    if (metadataRaw == null) {
      throw new Exception(
          'Metadata information for type ${type.displayName} was not found');
    }

    _encoder.write('output["$key"] = ');
    _decoder.writeln('output.$name = ');
    if (metadataRaw.isScalar) {
      final metadata = metadataRaw as ScalarTypeMetadata;
      if (isRepeated) {
        _encoder.write('input.$name.map((x) => '
            '${metadata.encodeString('x')}).toList()');
        _decoder.write('input["$key"].map((x) => '
            '${metadata.decodeString('x')}).toList()');
      } else {
        _encoder.write(metadata.encodeString('input.$name'));
        _decoder.write(metadata.decodeString('input["$key"]'));
      }
    } else {
      final metadata = metadataRaw as CompositeTypeMetadata;
      final displayName = metadata.displayName;
      if (isRepeated) {
        _encoder.write('input.$name.map((x) => '
            'const ${displayName}Encoder().convert(x)).toList()');
        _decoder.write('input["$key"].map((x) => '
            'const ${displayName}Decoder().convert(x)).toList()');
      } else {
        _encoder.write('const ${displayName}Encoder().convert(input.$name)');
        _decoder.write('const ${displayName}Decoder().convert(input["$key"])');
      }
    }
    _encoder.writeln(';');
    _decoder.writeln(';');
  }

  @override
  String build() {
    StringBuffer result = new StringBuffer();
    result.write(_decoder);
    result.write('return output;}}\n\n');
    result.write(_encoder);
    result.write('return output;}}\n\n');
    result.write(_codec);
    return result.toString();
  }
}
