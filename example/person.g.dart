// GENERATED CODE - DO NOT MODIFY BY HAND

part of typewriter.example.person;

// **************************************************************************
// Generator: TypewriterGenerator
// Target: class Person
// **************************************************************************

class PersonXmlDecoder extends Converter<Person, XmlNode> {
  const PersonXmlDecoder();

  Person convert(XmlNode input) {
    final output = new Person();

    output.name = input.findElements("name").first.text;
    output.age = input.findElements("age").first.text;
    output.money = input.findElements("money").first.text;
    output.isAlive = input.findElements("isAlive").first.text;
    output.birthday = input.findElements("birthday").first.text;
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
      output.element("birthday", nest: () {
        output.text(input.birthday);
      });
    });
    return output.build();
  }
}

class PersonXmlCodec extends Codec<Person, XmlNode> {
  static const PersonXmlEncoder _encoder = const PersonXmlEncoder();
  static const PersonXmlDecoder _decoder = const PersonXmlDecoder();

  const PersonXmlCodec();

  @override
  Converter<Person, XmlNode> get encoder => _encoder;

  @override
  Converter<XmlNode, Person> get decoder => _decoder;
}
