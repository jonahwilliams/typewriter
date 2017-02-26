part of typewriter.example.codecs;

class _PersonEncoder extends Converter<Person, Object> {
  _PersonEncoder();
  Object convert(Person input) {
    var output = <String, dynamic>{};
    output['name'] = input.name;
    output['age'] = input.age;
    output['money'] = input.money;
    output['is_alive'] = input.isAlive;
    output['item'] = new _ItemEncoder().convert(input.item);
    output['dog'] = new _DogEncoder().convert(input.dog);
    output['opaque'] = input.opaque.toString();
    return output;
  }
}

class _PersonDecoder extends Converter<Object, Person> {
  _PersonDecoder();
  Person convert(Object rawInput) {
    var input = rawInput as Map<String, dynamic>;
    var output = new Person();
    output.name = input['name'];
    output.age = input['age'];
    output.money = input['money'];
    output.isAlive = input['is_alive'];
    output.item = new _ItemDecoder().convert(input['item']);
    output.dog = new _DogDecoder().convert(input['dog']);
    output.opaque = new Symbol(input['opaque']);
    return output;
  }
}

class PersonCodec extends Codec<Object, Person> {
  PersonCodec();
  Converter<Person, Object> get encoder => new _PersonEncoder();
  Converter<Object, Person> get decoder => new _PersonDecoder();
}

class _ItemEncoder extends Converter<Item, Object> {
  _ItemEncoder();
  Object convert(Item input) {
    var output = <String, dynamic>{};
    output['name'] = input.name;
    output['id'] = input.id;
    output['description'] = input.description;
    output['why'] = input.why.toString();
    output['other'] = input.other;
    return output;
  }
}

class _ItemDecoder extends Converter<Object, Item> {
  _ItemDecoder();
  Item convert(Object rawInput) {
    var input = rawInput as Map<String, dynamic>;
    var output = new Item();
    output.name = input['name'];
    output.id = input['id'];
    output.description = input['description'];
    output.why = new RegExp(input['why']);
    output.other = input['other'];
    return output;
  }
}

class ItemCodec extends Codec<Object, Item> {
  ItemCodec();
  Converter<Item, Object> get encoder => new _ItemEncoder();
  Converter<Object, Item> get decoder => new _ItemDecoder();
}

class _DogEncoder extends Converter<Dog, Object> {
  _DogEncoder();
  Object convert(Dog input) {
    var output = <String, dynamic>{};
    output['names'] = input.names.map((x) => x).toList();
    output['age'] = input.age;
    output['birthday'] = input.birthday.toIso8601String();
    return output;
  }
}

class _DogDecoder extends Converter<Object, Dog> {
  _DogDecoder();
  Dog convert(Object rawInput) {
    var input = rawInput as Map<String, dynamic>;
    var output = new Dog();
    output.names = input['names'];
    output.age = input['age'];
    output.birthday = DateTime.parse(input['birthday']);
    return output;
  }
}

class DogCodec extends Codec<Object, Dog> {
  DogCodec();
  Converter<Dog, Object> get encoder => new _DogEncoder();
  Converter<Object, Dog> get decoder => new _DogDecoder();
}
