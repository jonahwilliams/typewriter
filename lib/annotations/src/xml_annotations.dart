part of typewriter.annotations;

class XmlElement implements DataAnnotation {
  @override
  final String key;

  @override
  final int position;

  const XmlElement(this.key, {@required this.position});
}

class XmlAttribute implements DataAnnotation {
  final String element;

  @override
  final String key;

  @override
  int get position => -1;

  const XmlAttribute(this.key, this.element);
}