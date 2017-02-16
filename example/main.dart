import 'person.dart';
import 'package:typewriter/codecs/codecs.dart';

void main() {
    const codec = const PersonXmlCodec();
    const xmlCodec = const XmlCodec();

    final person = new Person()
      ..name = "Jonah"
      ..age = 25
      ..money = 100.0
      ..isAlive = true
      ..birthday = new DateTime.now();

    print(codec.encode(person));
}
