part of typewriter.writer;

class JsonWriter extends Writer {
  const JsonWriter();

  String write(ClassDescription description) {
    final buffer = new StringBuffer();
    final name = description.type.displayName;

    // this format also depends on the type of strategy used, like
    // what kind of constructor.  this is hardcoded for the simple strategy
    buffer.write('''
    class ${name}JsonDecoder extends Converter<Object, $name> {
      const ${name}JsonDecoder();

      $name convert(Object raw) {
        final input = raw as Map<String, dynamic>;
        final output = new $name();

    ''');
    for (final field in description.fields) {
      // This is a hack because I haven't figured out a nice interface.
      buffer.writeln('output.${field.name} = input["${field.name}"];');
    }
    buffer.write('''
        return output;
      }
    }
    ''');

    ///
    ///
    buffer.write('''
    class ${name}JsonEncoder extends Converter<$name, Object> {
      const ${name}JsonEncoder();

      Object convert($name input) {
        final output = <String, dynamic>{};

    ''');
    for (final field in description.fields) {
      // This is a hack because I haven't figured out a nice interface.
      buffer.writeln('output["${field.name}"] = input.${field.name};');
    }
    buffer.write('''
        return output;
      }
    }
    ''');

    ///
    ///
    buffer.writeln('''
    class ${name}JsonCodec extends Codec<Object, $name> {
      static const _encoder = const ${name}JsonEncoder();
      static const _decoder = const ${name}JsonDecoder();

      const ${name}JsonCodec();

      @override
      Converter<String, Object> get encoder => _encoder;

      @override
      Converter<Object, String> get decoder => _decoder;
    }
    ''');
    return buffer.toString();
  }
}
