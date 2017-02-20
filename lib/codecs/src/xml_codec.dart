part of typewriter.codecs;

class _XmlEncoder extends Converter<XmlNode, String> {
  const _XmlEncoder();

  String convert(XmlNode input) => input.toXmlString(pretty: true);
}

class _XmlDecoder extends Converter<String, XmlNode> {
  const _XmlDecoder();

  XmlNode convert(String input) => parse(input);
}

class XmlCodec extends Codec<XmlNode, String> {
  static const _XmlEncoder _encoder = const _XmlEncoder();
  static const _XmlDecoder _decoder = const _XmlDecoder();

  const XmlCodec();

  @override
  Converter<XmlNode, String> get encoder => _encoder;

  @override
  Converter<String, XmlNode> get decoder => _decoder;
}
