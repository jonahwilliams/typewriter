part of typewriter.example.codecs;

const jsonCodec = const JsonCodec();

class PersonDecoder extends Converter<Object, Person> {
  const PersonDecoder();

  @override
  Person convert(Object raw) {
    var input = raw as Map<String, dynamic>;
    var output = new Person();
    output.name = input["name"];
    output.age = input["age"];
    output.money = input["money"];
    output.isAlive = input["is_alive"];
    output.item = const ItemDecoder().convert(input["item"]);
    output.dog = const DogDecoder().convert(input["dog"]);
    output.opaque = new Symbol(input["opaque"]);
    return output;
  }
}

class PersonEncoder extends Converter<Person, Object> {
  const PersonEncoder();

  @override
  Object convert(Person input) {
    var output = <String, dynamic>{};
    output["name"] = input.name;
    output["age"] = input.age;
    output["money"] = input.money;
    output["is_alive"] = input.isAlive;
    output["item"] = const ItemEncoder().convert(input.item);
    output["dog"] = const DogEncoder().convert(input.dog);
    output["opaque"] = input.opaque.toString();
    return output;
  }
}

class PersonCodec extends Codec<Person, Object> {
  const PersonCodec();

  @override
  Converter<Object, Person> get decoder => const PersonDecoder();

  @override
  Converter<Person, Object> get encoder => const PersonEncoder();
}

class ItemDecoder extends Converter<Object, Item> {
  const ItemDecoder();

  @override
  Item convert(Object raw) {
    var input = raw as Map<String, dynamic>;
    var output = new Item();
    output.name = input["name"];
    output.id = input["id"];
    output.description = input["description"];
    output.why = new RegExp(input["why"]);
    return output;
  }
}

class ItemEncoder extends Converter<Item, Object> {
  const ItemEncoder();

  @override
  Object convert(Item input) {
    var output = <String, dynamic>{};
    output["name"] = input.name;
    output["id"] = input.id;
    output["description"] = input.description;
    output["why"] = input.why.pattern;
    return output;
  }
}

class ItemCodec extends Codec<Item, Object> {
  const ItemCodec();

  @override
  Converter<Object, Item> get decoder => const ItemDecoder();

  @override
  Converter<Item, Object> get encoder => const ItemEncoder();
}

class DogDecoder extends Converter<Object, Dog> {
  const DogDecoder();

  @override
  Dog convert(Object raw) {
    var input = raw as Map<String, dynamic>;
    var output = new Dog();
    output.names = input["names"].map((x) => x).toList();
    output.age = input["age"];
    output.birthday = DateTime.parse(input["birthday"]);
    output.myFoo = new Foo(input["myFoo"]);
    return output;
  }
}

class DogEncoder extends Converter<Dog, Object> {
  const DogEncoder();

  @override
  Object convert(Dog input) {
    var output = <String, dynamic>{};
    output["names"] = input.names.map((x) => x).toList();
    output["age"] = input.age;
    output["birthday"] = input.birthday.toIso8601String();
    output["myFoo"] = input.myFoo.encode();
    return output;
  }
}

class DogCodec extends Codec<Dog, Object> {
  const DogCodec();

  @override
  Converter<Object, Dog> get decoder => const DogDecoder();

  @override
  Converter<Dog, Object> get encoder => const DogEncoder();
}
