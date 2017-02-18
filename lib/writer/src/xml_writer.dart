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

    for (var i = 0; i < description.fields.length; i++) {
      final field = description.fields[i];
      // This is a hack because I haven't figured out a nice interface.
      switch (field.type.displayName) {
        case 'int':
          buffer.writeln(
              'output.${field.name} = int.parse(input.children[$i].text);');
          break;
        case 'double':
          buffer.writeln(
              'output.${field.name} = double.parse(input.children[$i].text);');
          break;
        case 'DateTime':
          buffer.writeln(
              'output.${field.name} = DateTime.parse(input.children[$i].text);');
          break;
        case 'bool':
          buffer.writeln(
              'output.${field.name} = input.children[$i].text == "true";');
          break;
        default:
          buffer.writeln('output.${field.name} = input.children[$i].text;');
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
    class ${name}XmlCodec extends Codec<$name, XmlNode> {
      const ${name}XmlCodec();

      @override
      Converter<$name, XmlNode> get encoder => const PersonXmlEncoder();

      @override
      Converter<XmlNode, $name> get decoder => const PersonXmlDecoder();
    }
    ''');
    return buffer.toString();
  }
}
