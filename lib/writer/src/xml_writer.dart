part of typewriter.writer;


class XmlWriter extends Writer {

  const XmlWriter();

  String write(ClassDescription description) {
    final buffer = new StringBuffer();
    final name = description.type.displayName;

    // this format also depends on the type of strategy used, like
    // what kind of constructor.  this is hardcoded for the simple strategy
    buffer.write('''
    class ${name}XmlDecoder extends Converter<XmlNode, $name> {
      const ${name}XmlDecoder();

      $name convert(XmlNode input) {
        final output = new $name();

    ''');
    for (final field in description.fields) {
      // This is a hack because I haven't figured out a nice interface.
      buffer.writeln('output.${field.name} = findElements("${field.name}").first.text;');
    }
    buffer.write('''
        return output;
      }
    }
    ''');

    ///
    ///
    buffer.write('''
    class ${name}XmlEncoder extends Converter<$name, XmlNode> {
      const ${name}XmlEncoder();

      XmlNode convert($name input) {
        final output = new XmlBuilder();
        output.processing('xml', 'version="1.0"');
        output.element("$name", nest: () {

    ''');
    for (final field in description.fields) {
      // This is a hack because I haven't figured out a nice interface.
      final fieldName = field.name;
      buffer.write('''
        output.element("$fieldName", nest: () {
          output.text(input.${field.name});
        });
      ''');
    }
    buffer.write('''
        });
        return output.build();
      }
    }
    ''');

    ///
    ///
    buffer.writeln('''
    class ${name}XmlCodec extends Codec<XmlNode, $name> {
      static const _encoder = const ${name}XmlEncoder();
      static const _decoder = const ${name}XmlDecoder();

      const ${name}XmlCodec();

      @override
      Converter<String, XmlNode> get encoder => _encoder;

      @override
      Converter<XmlNode, String> get decoder => _decoder;
    }
    ''');
    return buffer.toString();
  }
}
