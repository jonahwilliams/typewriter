import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

import '../annotations/annotations.dart';

/// A collection of type information and metadata for a class to be serialized.
abstract class ClassDescription {
  List<FieldDescription> get fields;
  DartType get type;

  /// Is the class
  bool get isConstructor;

  @override
  int get hashCode => hash2(fields.fold(1327, (acc, x) => hash2(acc, x)), type);

  @override
  bool operator ==(Object other) =>
      other is ClassDescription &&
          other.type == type &&
          listsEqual(other.fields, fields);

  @override
  String toString() => 'ClassDescription for $type\n$fields';
}


class SimpleClassDescription implements ClassDescription {
  final List<FieldDescription> fields;
  final DartType type;
  bool get isConstructor => false;

  const SimpleClassDescription(this.type, this.fields);
}



abstract class FieldDescription {
  static const _simpleTypes = const [
    'List',
    'bool',
    'int',
    'double',
    'DateTime',
    'String'
  ];

  /// The name of the field in the source class.
  String get name;

  /// The type of the field.
  DartType get type;

  int get position;

  String get key;

  const FieldDescription();

  @override
  int get hashCode => hash2(name, type);

  @override
  bool operator ==(Object other) =>
      other is FieldDescription && other.name == name && other.type == type
      && position == other.position && other.key == key;

  bool get isUserDefined => !_simpleTypes.contains(type.displayName);
}

class SimpleDescription extends FieldDescription {
  @override
  final String name;

  @override
  final DartType type;

  @override
  final int position;

  @override
  final String key;

  const SimpleDescription(this.name, this.type, [String key, int position]):
      this.position = position ?? -1,
      this.key = key ?? name;
}