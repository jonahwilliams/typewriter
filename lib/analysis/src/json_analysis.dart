part of typewriter.analysis;

/// Performs an analysis where the source class only contains public fields.
class AnalysisJsonSimple implements Analysis {
  final SystemTypeProvider _typeProvider;

  /// Creates a simple analysis instance.
  AnalysisJsonSimple(this._typeProvider);

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
    final fields = <DescriptionJsonField>[];
    for (final field in element.fields) {
      if (field.metadata
          .any((an) => _typeProvider.isIgnore(an.constantValue.type))) {
        continue;
      }
      if (field.isFinal) {
        throw new ClassFinalFieldException(element.displayName);
      }
      final keyAnnotation = field.metadata.firstWhere(
          (annotation) =>
              _typeProvider.isPropertyJson(annotation.constantValue.type),
          orElse: () => null);
      final key =
          keyAnnotation?.constantValue?.getField('key')?.toStringValue();

      if (field.type.displayName.contains('List')) {
        final type = (field.type as ParameterizedType).typeArguments.first;
        fields.add(new DescriptionJsonField(field.name, type,
            repeated: true, key: key));
      } else {
        fields.add(new DescriptionJsonField(field.name, field.type, key: key));
      }
    }
    registry[element.type] = new Metadata.composite(element.name);

    return new DescriptionJson(element.displayName, fields);
  }
}

///// Performs analysis where the class is annotated with custom encoder and
///// decoders.
//class JsonAnalysisCustom implements Analysis {
//  final SystemTypeProvider _typeProvider;
//
//  /// Creates a simple analysis instance.
//  JsonAnalysisCustom(this._typeProvider);
//
//  @override
//  final List<Exception> errors = <Exception>[];
//
//  @override
//  void analyze(ClassElement element) {
//    final encoder = element.methods.firstWhere(
//        (el) => el.metadata.any((ann) =>
//            ann.constantValue.type.isAssignableTo(_typeProvider.jsonEncode)),
//        orElse: () => null);
//
//    if (encoder != null) {
//      final decoder = element.constructors.firstWhere(
//          (ctr) =>
//              ctr.isFactory &&
//              ctr.metadata.any((ann) => ann.constantValue.type
//                  .isAssignableTo(_typeProvider.jsonDecode)),
//          orElse: () => null);
//      if (decoder == null) {
//        errors
//            .add(new Exception('Cannot define a JsonEncode annotation without '
//                'a corresponding JsonDecode annotation'));
//      }
//      if (encoder.parameters.length != 0) {
//        errors
//            .add(new Exception('JsonEncode method must take zero arguments.'));
//      }
//      if (!encoder.returnType
//          .isAssignableTo(element.context.typeProvider.objectType)) {
//        errors.add(new Exception('JsonEncode method must return an Object'));
//      }
//      if (decoder.parameters.length != 1 ||
//          !decoder.parameters.first.type
//              .isAssignableTo(element.context.typeProvider.objectType)) {
//        errors
//            .add(new Exception('JsonDecode factory must take a single argument '
//                'of type Object'));
//      }
//
//      _registry.addType(
//          element.type,
//          new ScalarTypeMetadata(
//              element.type,
//              (x) => '$x.${encoder.name}()',
//              (x) => 'new ${element.name}'
//                  '${decoder.name != "" ? "." : ""}'
//                  '${decoder.name ?? ""}($x)'));
//    } else {
//      errors.add(new Exception('${element.displayName} was annotated with blah'
//          ' but doesnt have a customEncode and decode blah'));
//    }
//  }
//}
