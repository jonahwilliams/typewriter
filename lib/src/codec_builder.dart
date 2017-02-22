import 'package:analyzer/dart/element/type.dart';

import 'metadata.dart';

///
abstract class CodecBuilder {
  ///
  factory CodecBuilder.Json(MetadataRegistry registry, DartType type) {
    return new JsonCodecBuilder(registry, type);
  }

  ///
  void addField(
      String name, DartType type, bool isRepeated, String key, int position);

  /// Returns a String representing the Codec.
  String build();
}

///
class JsonCodecBuilder implements CodecBuilder {
  final MetadataRegistry _registry;
  final DartType _type;

  String _name;
  String _codec;

  final StringBuffer _encoder = new StringBuffer();
  final StringBuffer _decoder = new StringBuffer();

  ///
  JsonCodecBuilder(this._registry, this._type) {
    _name = _type.displayName;
    _codec = '''
    class ${_name}Codec extends Codec<$_name, Object> {
      const ${_name}Codec();

      @override
      Converter<Object, $_name> get decoder => const ${_name}Decoder();

      @override
      Converter<$_name, Object> get encoder => const ${_name}Encoder();
    }
    ''';
    _decoder.write('''
      class ${_name}Decoder extends Converter<Object, $_name> {

      const ${_name}Decoder();

      @override
      $_name convert(Object raw) {
        var input = raw as Map<String, dynamic>;
        var output = new $_name();
    ''');
    _encoder.write('''
      class ${_name}Encoder extends Converter<$_name, Object> {

      const ${_name}Encoder();

      @override
      Object convert($_name input) {
        var output = <String, dynamic>{};
    ''');
  }

  @override
  void addField(
      String name, DartType type, bool isRepeated, String key, int _) {
    final metadata = _registry.getType(type);
    if (metadata == null) {
      throw new Exception(
          'Metadata information for type ${type.displayName} was not found');
    }

    _encoder.write('output["$key"] = ');
    _decoder.writeln('output.$name = ');
    if (metadata is ScalarTypeMetadata) {
      if (isRepeated) {
        _encoder.write('input.$name.map((x) => '
            '${metadata.encodeString('x')}).toList()');
        _decoder.write('input["$key"].map((x) => '
            '${metadata.decodeString('x')}).toList()');
      } else {
        _encoder.write(metadata.encodeString('input.$name'));
        _decoder.write(metadata.decodeString('input["$key"]'));
      }
    } else if (metadata is CompositeTypeMetadata) {
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
    } else {}
    _encoder.writeln(';');
    _decoder.writeln(';');
  }

  @override
  String build() {
    final result = new StringBuffer()
      ..write(_decoder)
      ..write('return output;}}\n\n')
      ..write(_encoder)
      ..write('return output;}}\n\n')
      ..write(_codec);
    return result.toString();
  }
}
