library typewriter.annotations;

class Ignore {
  const Ignore();
}

/// Allows renaming of the JSON key associated with a field.
class PropertyJson {
  final String key;

  /// Creates a [JsonKey] annotation.
  const PropertyJson(this.key);
}

///
class Json {
  /// TODO: think of better name
  final bool useCustom;

  ///
  const Json({this.useCustom: false});
}

///
class EncodeJson {
  ///
  const EncodeJson();
}

///
class DecodeJson {
  ///
  const DecodeJson();
}

///
class ElementXml {
  final String key;

  ///
  const ElementXml(this.key);
}

///
class AttributeXml {
  ///
  final String element;

  final String key;

  ///
  const AttributeXml(this.key, this.element);
}

///
class Xml {
  ///
  const Xml();
}
