part of typewriter.annotations;

///
class XmlElement implements DataAnnotation {
  @override
  final String key;

  ///
  const XmlElement(this.key);
}

///
class XmlAttribute implements DataAnnotation {
  ///
  final String element;

  @override
  final String key;

  ///
  const XmlAttribute(this.key, this.element);
}

///
class Xml implements ClassAnnotation {
  ///
  const Xml();
}
