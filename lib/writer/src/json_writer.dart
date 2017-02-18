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
        final output = new $name();''');
    for (var i = 0; i < description.fields.length; i++) {
      final field = description.fields[i];
      if (field.isUserDefined) {
        buffer.writeln('output.${field.name} = (const ${field.type
                .displayName}JsonDecoder()).convert(input["${field.name}"]);');
      } else {
        switch (field.type.displayName) {
          case 'DateTime':
            buffer.writeln('output.${field.name} = '
                'DateTime.parse(input["${field.name}"]);');
            break;
          default:
            buffer.writeln('output.${field.name} = input["${field.name}"];');
        }
      }
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
        final output = <String, dynamic>{};''');
    for (var i = 0; i < description.fields.length; i++) {
      final field = description.fields[i];
      if (field.isUserDefined) {
        buffer.writeln(
            'output["${field.name}"] = (const ${field.type.displayName}'
            'JsonEncoder()).convert(input.${field.name});');
      } else {
        switch (field.type.displayName) {
          case 'DateTime':
            buffer.writeln('output["${field.name}"] = input.${field
                    .name}.toIso8601String();');
            break;
          default:
            buffer.writeln('output["${field.name}"] = input.${field.name};');
        }
      }
    }
    buffer.write('''
        return output;
      }
    }
    ''');

    buffer.writeln('''
    class _${name}JsonCodec extends Codec<$name, Object> {
      const _${name}JsonCodec();

      @override
      Converter<$name, Object> get encoder => const ${name}JsonEncoder();

      @override
      Converter<Object, $name> get decoder => const ${name}JsonDecoder();
    }
    final ${name.toLowerCase()}JsonCodec = const _${name}JsonCodec().fuse(jsonCodec);
    ''');
    return buffer.toString();
  }
}
