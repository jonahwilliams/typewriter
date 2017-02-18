# typewriter

Given a simple Dart class like this, generate an encoder/decoder class for any
number of different serialization formats.


```dart
class Person {
  int age;
  DateTime birthday;
  String name;
}
```

Typewriter generates a codec, containing code which looks something like this.



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

```json
{ "foo_bar": "My foo's"}
```

Or making a field into an attribute on an Xml node

```dart
class Bar {
  String language;

  @Attribute()
  int id;
}
```

```xml
<?xml version="1.0"?>
<Bar id="23">
  <language>English</language>
</Bar>
```


These annotations will be added as configuration needs are discovered.

### Analysis
Use the analyzer to inspect the fields, constructors, types of a class and produce a description of the
necessary codec logic.

For now it only accepts classes with a no argument default constructor, all public fields, et cetera.
This is the easiest to implement, but leaves out immutable classes and initialization logic.

In later versions, we can handle the above, but also allow an annotated constructor and final fields.
Using some heuristic to match a constructor argument with a final field to assure that everything can
be initialized.

Support for Inheritance and Generics will be considered If it makes sense at some point in the future.


### Writers
using the class description from analysis, generate a class which can encode and decode.

A Codec is generated for each target language, then that codec is fused with the language specific
serializer to produce a codec capable of converting between a type and it's xml/json string representation.
```
  [Class Person] --> [Codec: Person -> Xml]  + [Codec Xml -> String]
                 --> [Codec: Person -> Json] + [Codec Json -> String]

```


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
