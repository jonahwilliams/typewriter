# typewriter
A Jackson-like library for dart serialization.  It's high level goals are,

1. Performance
  Use code generation instead of mirrors/meta-programming to create serializers
  which are as performant as you would write by hand
2. Easy to use
  Use sane defaults and helpful errors/documentation.
3. Lightly configurable
  Annotation based configuration instead of configuration files.


## Initial version API


Given a simple Dart class like this, generate an encoder/decoder class for any
number of different serialization formats.
```dart
class Person {
  int age;
  DateTime birthday;
  String name;
}
```

For example a JSON codec might work by first converting the object into
something that can already be serialized by dart's JSON parser.
```dart
Object convert(Person person) {
   return {
     'age': person.age,
     'birthday': person.birthday.toIso8601String(),
     'name': person.name,
   };
}
```

In the future, it would be easier to support parsing directly to
 a String, (if that is faster)
```
String convert(Person person) {
    return '''{
      "age": ${person.age},
      "birthday": "${person.birthday.toIso8601String()}",
      "name": "${person.name}"
    }''';
}
```


## Design
The following is in progress work on the overall design of the library.

### Annotation/Configuration
Annotations should be used to provide extra information to the library and
provide a limited way of configuration.

for example, renaming a property in a JSON map.
```dart
class Foo {
  @Field(key: 'foo_bar')
  String fooBar;
}
```
These annotations will be added as configuration needs are discovered.

### Class Analyzer
The class analyzer produces a description of a class which a codec can be
created from. For example, in the above class Person, the analyzer will examine
the ClassElement and find the type and name of all public fields.  There are
actually several different strategies towards analyzing classes - ideally as
many as necessary could be supported.

  * Pojo (Podo?) style.
    Only accept classes with a default constructor and all public fields.  This
    is the easiest to implement, but leaves out immutable classes and
    initialization logic.
  * Annotated constructor.
    Handle the above, but also allow an annotated constructor and final fields.
    Find some heuristic to match a constructor argument with a final field to
    assure that all are covered.

Todos here:

1. How do I get type information from a class, i.e. use DartType?
2. How can I match up setters and getters - only to the same private field?
3. How do I analyze constructor arguments.
4. How to handle inheritance? I am leaning towards ignoring it.

```
abstract class ClassDescription {
  String get name;
  DartType get type;
  List<FieldDescription> get fields;
}

abstract class FieldDescription {
  String get name;
  String get field;
  DartType get type;
}
```
### Codec Generator
The codec generator takes a ClassDescription and produces some sort of codec
based on it.  It needs to know what the output type is as well, how to abstract
this?

Here we could use the existing JSON codec (will this work for xml, yaml, proto,
  avro, et cetera?)
```
Codec<String, Object> + Codec<Object, Foo>
```

Probably not, but at some point we'd need an intermediary format for all of
these parsers ... why?  for nesting. In general there are several different
things that need to be done.

1. Match dart type to source type
    for example Dart to JSON
      String -> String,
      int -> int,
      double -> double,
      bool -> boolean,
      DateTime -> String,
      Int64 -> String
      Person -> { name :: String, age :: double }

    So there are several issues here, one is there are 'simple' types like
    DateTime and Int64 which have only one value.  Then there are more complex
    types like our Person type, which needs to map to an object, or be nested
    in someway.

For DateTime
```dart
String encode(DateTime dateTime) => dateTime.toIso8601String();

DateTime decode(String input) => DateTime.parse(input);
```

But complex types either need to go straight to a string or to an intermediary
format.  In the case of JSON, this would be a Map<String, dynamic>

Do I need to make a distinction between 'Simple' types and complex ones? or
can this be handled entire though an input -> output type map

1. Given a DartType and a Destination, Determine DestinationType.  this should
 probably be fixed for basic and stdlib types.
  DateTime + JSON -> String
2. Lookup DartType -> DestinationType function
  String encode(DateTime dateTime) => dateTime.toIso8601String()



### Build Process (In progress)
Because these types can be nested, we need to determine what types are
available before we can start generating codecs.

1. Determine the full list of classes which need to have codecs.  Ensure that
there are no definitions missing and everything is available (fail fast).

Something something make sure types are resolved and stuff.

2. Begin generating codecs in the same directory.  Maybe use code builder instead
of strings.


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
