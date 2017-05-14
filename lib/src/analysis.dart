import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'metadata.dart';
import 'exceptions.dart';
import 'system_type_provider.dart';

/// Performs analysis on a [ClassElement] to determine if a valid codec can
/// be constructed.
abstract class Analysis {
  const Analysis();

  BuildsCodec analyze(
    ClassElement element,
    Map<DartType, Metadata> registry,
  );
}

/// Performs an analysis where the source class only contains public fields.
class JsonAnalysis implements Analysis {
  final SystemTypeProvider _typeProvider;

  const JsonAnalysis(this._typeProvider);

  @override
  BuildsCodec analyze(ClassElement element, Map<DartType, Metadata> registry) {
    // May not use inheritance
    if (!element.supertype.isObject) {
      throw new ClassUsingExtendsKeywordException(element.displayName);
    }
    // May not have a default ctr with arguments.
    if (element.unnamedConstructor?.isDefaultConstructor == null) {
      throw new ClassNoArgConstructorException(element.displayName);
    }

    // May not have final fields
    // static fields are OK, and any fields with @Ignore are completely ignored.
    var fields = <JsonFieldDescription>[];
    for (var field in element.fields) {
      if (field.metadata
          .any((an) => _typeProvider.isIgnore(an.constantValue.type))) {
        continue;
      }
      if (field.isFinal) {
        throw new ClassFinalFieldException(element.displayName);
      }
      var keyAnnotation = field.metadata.firstWhere(
        (annotation) =>
            _typeProvider.isJsonProperty(annotation.constantValue.type),
        orElse: () => null,
      );
      var key = keyAnnotation?.constantValue?.getField('key')?.toStringValue();

      if (field.type.displayName.contains('List')) {
        var type = (field.type as ParameterizedType).typeArguments.first;
        fields.add(new JsonFieldDescription(field.name, type,
            repeated: true, key: key));
      } else {
        fields.add(new JsonFieldDescription(field.name, field.type, key: key));
      }
    }
    registry[element.type] = new Metadata.composite(element.name);

    return new JsonDescription(element.displayName, fields);
  }
}

class XmlAnalysis implements Analysis {
  final SystemTypeProvider _typeProvider;

  /// Creates a simple analysis instance.
  const XmlAnalysis(this._typeProvider);

  @override
  BuildsCodec analyze(ClassElement element, Map<DartType, Metadata> registry) {
    // May not use inheritance
    if (!element.supertype.isObject) {
      throw new ClassUsingExtendsKeywordException(element.displayName);
    }
    // May not have a default ctr with arguments.
    if (element.unnamedConstructor?.isDefaultConstructor == null) {
      throw new ClassNoArgConstructorException(element.displayName);
    }

    // May not have final fields
    // static fields are OK, and any fields with @Ignore are completely ignored.
    var fields = <XmlElementDescription>[];
    for (var field in element.fields) {
      if (field.metadata
          .any((an) => _typeProvider.isIgnore(an.constantValue.type))) {
        continue;
      }
      if (field.isFinal) {
        throw new ClassFinalFieldException(element.displayName);
      }
      fields.add(new XmlElementDescription(
          field.name, field.name, false, field.type, []));
    }
    registry[element.type] = new Metadata.composite(element.name);

    return new XmlDescription(
        element.displayName, element.displayName, fields, []);
  }
}
