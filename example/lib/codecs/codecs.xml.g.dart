part of typewriter.example.codecs;

class _ItemEncoder extends Converter<Item, XmlElement> {
  _ItemEncoder();

  XmlElement convert(Item input) {
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

class _ItemDecoder extends Converter<XmlElement, Item> {
  _ItemDecoder();

  Item convert(XmlElement input) {
    final output = new Item();
    output.name = input.findElements('name').first.text;
    output.id = int.parse(input.findElements('id').first.text);
    output.description = input.findElements('description').first.text;
    output.why = new RegExp(input.findElements('why').first.text);
    return output;
  }
}

class ItemCodec extends Codec<Item, XmlElement> {
  ItemCodec();

  Converter<Item, XmlElement> get encoder => new _ItemEncoder();

  Converter<XmlElement, Item> get decoder => new _ItemDecoder();
}
