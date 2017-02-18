part of typewriter.writer;

class YamlWriter extends Writer {
  const YamlWriter();

  String write(ClassDescription description) {
    final buffer = new StringBuffer();
    final name = description.type.displayName;

    // this format also depends on the type of strategy used, like
    // what kind of constructor.  this is hardcoded for the simple strategy
    buffer.write('''
    class ${name}Decoder extends Converter<Object, $name> {
      const ${name}Decoder();

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
    class ${name}Encoder extends Converter<$name, Object> {
      const ${name}Encoder();

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
    class ${name}Codec extends Codec<Object, $name> {
      static const _encoder = const ${name}Encoder();
      static const _decoder = const ${name}Decoder();

      const ${name}Codec();

      @override
      Converter<String, Object> get encoder => _encoder;

      @override
      Converter<Object, String> get decoder => _decoder;
    }
    ''');
    return buffer.toString();
  }
}
