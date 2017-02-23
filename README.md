# typewriter

Given a simple Dart class like this, generate an encoder/decoder class for any
number of different serialization formats.  Not currently stable.

Anootations allow lite configuration of the serialized classes.
```dart
@Json()
class Person {
  int age;
  @JsonKey('birth_day')
  DateTime birthDay;
  String name;
}
```
Prodcuces the resulting JSON.
```json
{ "age": 25, "birth_day": "some-long-iso-string", "name": "Jonah"}
```

And for XML,

```dart
@Xml('FooBar')
class ApiResponse {
  @XmlElement('name-list', 'name')
  List<String> names;
  
  @XmlAttribute('name-length', element: 'name-list')
  int lenth;
}
```

```xml
<?xml version="1.0"?>
<FooBar>
  <name-list length="3">
    <name>Peter Parker</name>
    <name>Bruce Wayne</name>
    <name>Snoop Dogg</name>
  </name-list>
</FooBar>
```

You can also specify custom encoders/decoders for classes.

```dart
@Json()
class Dog {  
  @JsonDecoder()
  factory Dog(Object input) {
    return new Dog._();
  }
  
  Dog._();
  
  @JsonEncoder()
  Object encode() {
    return {'bark': 'woof'};
  }
}
```

### Annotation/Configuration
Annotations should be used to provide extra information to the library and
provide a limited way of configuration.  These annotations will be added as configuration needs are discovered.

### Analysis
Use the analyzer to inspect the fields, constructors, types of a class and produce a description of the
necessary codec logic.

For now it only accepts classes with a no argument default constructor, all public fields, et cetera.
This is the easiest to implement, but leaves out immutable classes and initialization logic.

In later versions, we can handle the above, but also allow an annotated constructor and final fields.
Using some heuristic to match a constructor argument with a final field to assure that everything can
be initialized.

Support for Inheritance and Generics will be considered If it makes sense at some point in the future.


### CodecBuilders
using the class description from analysis, generate a class which can encode and decode the
 Object from a String.  Currently this is done by converting it into an already serializable format and 
 then using other libraries.  This may change in the future.


## Features and bugs
