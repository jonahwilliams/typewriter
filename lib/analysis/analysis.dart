import '../descriptions/descriptions.dart';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';
import 'package:resolver/src/analyzer.dart';


/// A way of determining if a class can be serialized.
abstract class AnalysisStrategy {
  const AnalysisStrategy();

  ClassDescription analyze(ClassElement element, AnalysisContext context);
}

/// A method of analyzing which only allows classes with default
/// constructors and public fields.
class SimpleStrategy implements AnalysisStrategy {
  const SimpleStrategy();

  ClassDescription analyze(ClassElement element, AnalysisContext context) {
    final typeProvider = context.typeProvider;

    if (element.supertype.displayName != 'Object') {
      throw new Exception('Cannot use ${element.name} because it uses '
          'inheritance or mixins.');
    }

    if (!(element.unnamedConstructor?.isDefaultConstructor ?? true)) {
      throw new Exception('Cannot use ${element.name} because it has no '
          'default constructor.');
    }

    final fields = <FieldDescription>[];
    loop: for (final field in element.fields) {
      if (field.isFinal) {
        throw new Exception('Cannot use ${element.name} because it has final '
            'fields');
      }
      if (field.isPublic) {
        String key;
        int position;
        // TODO: find a better way to do this.
        for (final annotation in field.metadata) {
          final value = annotation?.constantValue ?? annotation.computeConstantValue();
          if (value.type.displayName == 'ignore') {
            continue loop;
          }
          if (value.type.displayName == 'JsonKey') {
            key = value.getField('key').toStringValue();
            position = value.getField('position').toIntValue();
          }
        }
        fields.add(new SimpleDescription(field.name, field.type));
      }
    }
    return new SimpleClassDescription(element.type, fields);
  }
}
