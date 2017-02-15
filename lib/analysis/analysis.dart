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
}

/// Type information and metadata for a field to be serialized.
class FieldDescription {
  final String name;
  final DartType type;

  const FieldDescription(this.name, this.type);

  @override
  int get hashCode => hash2(name, type);

  @override
  bool operator ==(Object other) =>
      other is FieldDescription && other.name == name && other.type == type;
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
    // TODO: find a better way to know if a class extends or mixes in something
    if (element.hasReferenceToSuper) {
      throw new Exception('Cannot use ${element.name} because it uses '
          'inheritance or mixins.');
    }

    // TODO: check that there is no default ctr, or default ctr has no params.
    // if (element?.unnamedConstructor?.parameters?.isEmpty == true) {
    //   throw new Exception('Cannot use ${element.name} because it has no '
    //     'default constructor.');
    // }

    final fields = element.fields
        .where((field) =>
            !field.isFinal &&
            !field.isConst &&
            !field.isStatic &&
            field.isPublic)
        .map((field) {
      return new FieldDescription(field.name, field.type);
    }).toList();
    return new ClassDescription(element.type, fields);
  }
}
