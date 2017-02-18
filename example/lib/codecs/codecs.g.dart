part of typewriter.example.codecs;

const jsonCodec = const JsonCodec();
const xmlCodec = const XmlCodec();

class PersonJsonDecoder extends Converter<Object, Person> {
  const PersonJsonDecoder();

  Person convert(Object raw) {
    final input = raw as Map<String, dynamic>;
    final output = new Person();
    output.name = input["name"];
    output.age = input["age"];
    output.money = input["money"];
    output.isAlive = input["isAlive"];
    output.birthday = DateTime.parse(input["birthday"]);
    output.item = (const ItemJsonDecoder()).convert(input["item"]);
    output.dog = (const DogJsonDecoder()).convert(input["dog"]);
    return output;
  }
}

class PersonJsonEncoder extends Converter<Person, Object> {
  const PersonJsonEncoder();

  Object convert(Person input) {
    final output = <String, dynamic>{};
    output["name"] = input.name;
    output["age"] = input.age;
    output["money"] = input.money;
    output["isAlive"] = input.isAlive;
    output["birthday"] = input.birthday.toIso8601String();
    output["item"] = (const ItemJsonEncoder()).convert(input.item);
    output["dog"] = (const DogJsonEncoder()).convert(input.dog);
    return output;
  }
}

class _PersonJsonCodec extends Codec<Person, Object> {
  const _PersonJsonCodec();

  @override
  Converter<Person, Object> get encoder => const PersonJsonEncoder();

  @override
  Converter<Object, Person> get decoder => const PersonJsonDecoder();
}

final personJsonCodec = const _PersonJsonCodec().fuse(jsonCodec);

class ItemJsonDecoder extends Converter<Object, Item> {
  const ItemJsonDecoder();

  Item convert(Object raw) {
    final input = raw as Map<String, dynamic>;
    final output = new Item();
    output.name = input["name"];
    output.id = input["id"];
    output.description = input["description"];
    return output;
  }
}

class ItemJsonEncoder extends Converter<Item, Object> {
  const ItemJsonEncoder();

  Object convert(Item input) {
    final output = <String, dynamic>{};
    output["name"] = input.name;
    output["id"] = input.id;
    output["description"] = input.description;
    return output;
  }
}

class _ItemJsonCodec extends Codec<Item, Object> {
  const _ItemJsonCodec();

  @override
  Converter<Item, Object> get encoder => const ItemJsonEncoder();

  @override
  Converter<Object, Item> get decoder => const ItemJsonDecoder();
}

final itemJsonCodec = const _ItemJsonCodec().fuse(jsonCodec);

class DogJsonDecoder extends Converter<Object, Dog> {
  const DogJsonDecoder();

  Dog convert(Object raw) {
    final input = raw as Map<String, dynamic>;
    final output = new Dog();
    output.name = input["name"];
    output.age = input["age"];
    output.birthday = DateTime.parse(input["birthday"]);
    return output;
  }
}

class DogJsonEncoder extends Converter<Dog, Object> {
  const DogJsonEncoder();

  Object convert(Dog input) {
    final output = <String, dynamic>{};
    output["name"] = input.name;
    output["age"] = input.age;
    output["birthday"] = input.birthday.toIso8601String();
    return output;
  }
}

class _DogJsonCodec extends Codec<Dog, Object> {
  const _DogJsonCodec();

  @override
  Converter<Dog, Object> get encoder => const DogJsonEncoder();

  @override
  Converter<Object, Dog> get decoder => const DogJsonDecoder();
}

final dogJsonCodec = const _DogJsonCodec().fuse(jsonCodec);
