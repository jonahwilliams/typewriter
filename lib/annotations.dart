library typewriter.annotations;

/// Marks a field to be ignored by typewriter.
class ignore {
  const ignore();
}

/// Renames a field to [key] in Json.
class jsonProperty {
  final String key;

  const jsonProperty(this.key);
}

/// Marks a class for Json codec generation.
class deriveJson {
  const deriveJson();
}

/// Marks a class for XML codec generation.
class deriveXml {
  const deriveXml();
}

/// Renames a field to [key] in xml.
class xmlElement {
  final String key;

  const xmlElement(this.key);
}

/// Renames a field to [key] and places it as an attribute of [element].
class xmlAttribute {
  final String element;
  final String key;

  const xmlAttribute(this.key, this.element);
}
