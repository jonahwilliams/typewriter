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

class _ItemEncoder extends Converter<Item, Object> {
  _ItemEncoder();
  Object convert(Item input) {
    var output = <String, dynamic>{};
    output['name'] = input.name;
    output['id'] = input.id;
    output['description'] = input.description;
    output['why'] = input.why.toString();
    return output;
  }
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
