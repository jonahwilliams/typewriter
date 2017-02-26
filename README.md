# Typewriter [![Build Status](https://travis-ci.org/jonahwilliams/typewriter.svg?branch=master)](https://travis-ci.org/jonahwilliams/typewriter)

<b>Typewritter</b> is a Dart library for generating [codecs](https://www.dartlang.org/articles/libraries/converters-and-codecs), encoder/decoder pairs for serialization.  Serialization code is repetitive and time consuming to write.  Instead of using reflection/mirrors, Typewriter enables developers to generate configurable codecs automatically from Dart source code.

The supported target languages are
* JSON
* XML (partial)
* Yaml (planned) 

This library is currently under active development and is not stable enough for non-experimental use.

## Example Usage
Typewriter annotations configure the behavior of the generated codecs.  For example, the following Class uses a `JsonKey` annotation, which changes the name of the field on the resulting JSON.

```dart
@Json()
class Person {
  int age;
  @JsonKey('birth_day')
  DateTime birthDay;
  String name;
  Cat myCat;
}

@Json()
class Cat {
  String name;
}
```
An instance of this class serialized to JSON would look something like the following.

```json
{ "age": 25, "birth_day": "some-long-iso-string", "name": "Jonah", "myCat": {"name": "Mike Hat"}}
```

Xml annotations support configuring the names of elements and child elements with `XmlElement`.  The annotation `XmlAttribute` allows developers to place annotations on any of the elements in the class.

```dart
@Xml('FooBar')
class ApiResponse {
  @XmlElement('name-list', 'name')
  List<String> names;
  
  @XmlAttribute('name-length', element: 'name-list')
  int lenth;
}
```
The following is an instance of `ApiResponse` serialized to XML.  Typewriter also handles the xml header.
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

In case a developer needs to implement specific serialization logic, Typewriter allows specification of `Encoder` and `Decoder` annotations.

```dart
@Json(customEncoder: true)
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

Checkout examples/.. for some examples of the generated code.
