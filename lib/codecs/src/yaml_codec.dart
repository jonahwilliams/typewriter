part of typewriter.codecs;

class _YamlDecoder extends Converter<String, YamlNode> {
  const _YamlDecoder();

  YamlNode convert(String input) => loadYaml(input);
}

class _YamlEncoder extends Converter<YamlNode, String> {
  const _YamlEncoder();

  String convert(YamlNode input) {
    // TODO
    return '';
  }
}

class YamlCodec extends Codec<YamlNode, String> {
  static const _YamlDecoder _decoder = const _YamlDecoder();
  static const _YamlEncoder _encoder = const _YamlEncoder();

  const YamlCodec();

  @override
  Converter<String, YamlNode> get decoder => _decoder;

  @override
  Converter<YamlNode, String> get encoder => _encoder;
}
