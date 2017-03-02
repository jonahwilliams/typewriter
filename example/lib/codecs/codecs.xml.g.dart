part of typewriter.example.codecs;

class _XmlEncoder extends Converter<XmlNode, String> {
  String convert(XmlNode input) {
    final processing = new XmlProcessing('xml', 'version="1.0"');
    return new XmlDocument([processing, input]).toString();
  }
}

class _XmlDecoder extends Converter<String, XmlNode> {
  XmlNode convert(String input) {
    return parse(input).rootElement;
  }
}

class _XmlCodec extends Codec<XmlNode, String> {
  Converter<XmlNode, String> get encoder => new _XmlEncoder();

  Converter<String, XmlNode> get decoder => new _XmlDecoder();
}

class _ItemEncoder extends Converter<Item, XmlNode> {
  _ItemEncoder();

  XmlNode convert(Item input) {
    return new XmlElement(new XmlName('Item'), [], [
      new XmlElement(new XmlName('name'), const [], [new XmlText(input.name)]),
      new XmlElement(
          new XmlName('id'), const [], [new XmlText(input.id.toString())]),
      new XmlElement(new XmlName('description'), const [],
          [new XmlText(input.description)]),
      new XmlElement(
          new XmlName('why'), const [], [new XmlText(input.why.toString())])
    ]);
  }
}

class _ItemDecoder extends Converter<XmlNode, Item> {
  _ItemDecoder();

  Item convert(XmlNode inputRaw) {
    final input = inputRaw as XmlElement;
    if (input.name.local != 'Item') {
      throw new Exception('');
    }
    final output = new Item();
    output.name = input.findElements('name').first.text;
    output.id = int.parse(input.findElements('id').first.text);
    output.description = input.findElements('description').first.text;
    output.why = new RegExp(input.findElements('why').first.text);
    return output;
  }
}

class ItemCodec extends Codec<Item, XmlNode> {
  ItemCodec();

  Converter<Item, XmlNode> get encoder => new _ItemEncoder();

  Converter<XmlNode, Item> get decoder => new _ItemDecoder();
}

final Codec<Item, String> itemXmlCodec = new ItemCodec().fuse(new _XmlCodec());
