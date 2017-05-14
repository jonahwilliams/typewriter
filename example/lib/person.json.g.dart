part of typewriter.example.person;

class _PersonEncoder extends Converter<Person, Map<String, dynamic>> {
  _PersonEncoder();

  Map<String, dynamic> convert(Person input) {
    var output = <String, dynamic>{};
    output['name'] = input.name;
    output['age'] = input.age;
    output['money'] = input.money;
    output['is_alive'] = input.isAlive;
    output['opaque'] = input.opaque.toString();
    return output;
  }
}

class _PersonDecoder extends Converter<Map<String, dynamic>, Person> {
  _PersonDecoder();

  Person convert(Map<String, dynamic> input) {
    var output = new Person();
    output.name = input['name'];
    output.age = input['age'];
    output.money = input['money'];
    output.isAlive = input['is_alive'];
    output.opaque = new Symbol(input['opaque']);
    return output;
  }
}

class PersonCodec extends Codec<Person, Map<String, dynamic>> {
  PersonCodec();

  Converter<Person, Map<String, dynamic>> get encoder => new _PersonEncoder();

  Converter<Map<String, dynamic>, Person> get decoder => new _PersonDecoder();
}
