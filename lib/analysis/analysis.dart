import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

/// A collection of type information and metadata for a class to be serialized.
class ClassDescription {
  final List<FieldDescription> fields;
  final DartType type;

  const ClassDescription(this.type, this.fields);

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

abstract class FieldDescription {
  static const _simpleTypes = const [
    'List',
    'bool',
    'int',
    'double',
    'DateTime',
    'String'
  ];

  String get name;
  DartType get type;
  int get position;

  const FieldDescription();


  @override
  int get hashCode => hash2(name, type);

  @override
  bool operator ==(Object other) =>
      other is FieldDescription && other.name == name && other.type == type;

  bool get isUserDefined => !_simpleTypes.contains(type.displayName);
}

class SimpleDescription extends FieldDescription {
  final position = -1;
  final String name;
  final DartType type;

  const SimpleDescription(this.name, this.type);
}



/// A way of determining if a class can be serialized.
abstract class AnalysisStrategy {
  const AnalysisStrategy();

  ClassDescription analyze(ClassElement element);
}

/// A method of analyzing which only allows classes with default
/// constructors and public fields.
class SimpleStrategy implements AnalysisStrategy {
  const SimpleStrategy();

  ClassDescription analyze(ClassElement element) {
    if (element.supertype.displayName != 'Object') {
      throw new Exception('Cannot use ${element.name} because it uses '
          'inheritance or mixins.');
    }

    if (!(element.unnamedConstructor?.isDefaultConstructor ?? true)) {
       throw new Exception('Cannot use ${element.name} because it has no '
         'default constructor.');
    }

    final fields = <FieldDescription>[];
    for (final field in element.fields) {
      if (field.isFinal) {
        throw new Exception('Cannot use ${element.name} because it has final '
            'fields');
      }
      if (field.isPublic) {
        fields.add(new SimpleDescription(field.name, field.type));
      }
    }
    return new ClassDescription(element.type, fields);
  }
}
