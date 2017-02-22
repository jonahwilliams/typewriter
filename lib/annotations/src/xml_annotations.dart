part of typewriter.annotations;

///
class XmlElement implements DataAnnotation {
  @override
  final String key;

  @override
  final int position;

  ///
  const XmlElement(this.key, {this.position = -1});
}

///
class XmlAttribute implements DataAnnotation {
  ///
  final String element;

  @override
  final String key;

  @override
  final int position = -1;

  ///
  const XmlAttribute(this.key, this.element);
}

///
class Xml implements ClassAnnotation {
  ///
  const Xml();
}
