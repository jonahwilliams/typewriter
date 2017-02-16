// GENERATED CODE - DO NOT MODIFY BY HAND

part of typewriter.example.person;

// **************************************************************************
// Generator: TypewriterGenerator
// Target: class Person
// **************************************************************************

class PersonXmlDecoder extends Converter<XmlNode, Person> {
  const PersonXmlDecoder();

  Person convert(XmlNode input) {
    final output = new Person();

    output.name = findElements("name").first.text;
    output.age = findElements("age").first.text;
    output.money = findElements("money").first.text;
    output.isAlive = findElements("isAlive").first.text;
    return output;
  }
}

class PersonXmlEncoder extends Converter<Person, XmlNode> {
  const PersonXmlEncoder();

  XmlNode convert(Person input) {
    final output = new XmlBuilder();
    output.processing('xml', 'version="1.0"');
    output.element("Person", nest: () {
      output.element("name", nest: () {
        output.text(input.name);
      });
      output.element("age", nest: () {
        output.text(input.age);
      });
      output.element("money", nest: () {
        output.text(input.money);
      });
      output.element("isAlive", nest: () {
        output.text(input.isAlive);
      });
    });
    return output.build();
  }
}

class PersonXmlCodec extends Codec<Object, XmlNode> {
  static const _encoder = const PersonXmlEncoder();
  static const _decoder = const PersonXmlDecoder();

  const PersonXmlCodec();

  @override
  Converter<String, XmlNode> get encoder => _encoder;

  @override
  Converter<XmlNode, String> get decoder => _decoder;
}
