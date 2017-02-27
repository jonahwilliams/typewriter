part of typewriter.example.codecs;

class _ItemEncoder extends Converter<Item, XmlNode> {
  _ItemEncoder();

  XmlNode convert(Item input) {
    var builder = new XmlBuilder();
    builder.element('Item', nest: () {
      builder.element('name', nest: () {
        builder.text(input.name);
      });
      builder.element('id', nest: () {
        builder.text(input.id.toString());
      });
      builder.element('description', nest: () {
        builder.text(input.description);
      });
      builder.element('why', nest: () {
        builder.text(input.why.toString());
      });
    });
    return builder.build();
  }
}

class _ItemDecoder extends Converter<XmlNode, Item> {
  _ItemDecoder();

  Item convert(XmlNode inputRaw) {
    var input = inputRaw as XmlElement;
    if (input.name.value != 'Item') {
      throw new Exception("");
    }
    var output = new Item();
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
