// GENERATED CODE - DO NOT MODIFY BY HAND

part of typewriter.example.person;

// **************************************************************************
// Generator: TypewriterGenerator
// Target: class Person
// **************************************************************************

class PersonDecoder extends Converter<Object, Person> {
  const PersonDecoder();

  Person convert(Object raw) {
    final input = raw as Map<String, dynamic>;
    final output = new Person();

    output.name = input["name"];
    output.age = input["age"];
    output.money = input["money"];
    output.isAlive = input["isAlive"];
    return output;
  }
}

class PersonEncoder extends Converter<Person, Object> {
  const PersonEncoder();

  Object convert(Person input) {
    final output = <String, dynamic>{};

    output["name"] = input.name;
    output["age"] = input.age;
    output["money"] = input.money;
    output["isAlive"] = input.isAlive;
    return output;
  }
}

class PersonCodec extends Codec<Object, Person> {
  static const _encoder = const PersonEncoder();
  static const _decoder = const PersonDecoder();

  const PersonCodec();

  @override
  Converter<String, Object> get encoder => _encoder;

  @override
  Converter<Object, String> get decoder => _decoder;
}
