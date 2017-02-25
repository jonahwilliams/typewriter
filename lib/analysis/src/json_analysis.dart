part of typewriter.analysis;

/// Performs an analysis where the source class only contains public fields.
class JsonAnalysisSimple implements Analysis {
  final SystemTypeProvider _typeProvider;
  final MetadataRegistry _registry;

  /// Creates a simple analysis instance.
  JsonAnalysisSimple(this._typeProvider, this._registry);

  @override
  final List<Exception> errors = <Exception>[];

  @override
  void analyze(ClassElement element) {
    // May not use inheritance
    if (!element.supertype.isObject) {
      errors.add(new ClassUsingExtendsKeywordException(element.displayName));
      return;
    }
    // May not have a default ctr with arguments.
    if (element.unnamedConstructor?.isDefaultConstructor == null) {
      errors.add(new ClassNoArgConstructorException(element.displayName));
      return;
    }

    // May not have final fields
    // static fields are OK, and any fields with @Ignore are completely ignored.
    final fields = <FieldElement>[];
    for (final field in element.fields) {
      if (field.metadata.any(
          (an) => an.constantValue.type.isAssignableTo(_typeProvider.ignore))) {
        continue;
      }
      if (field.isFinal) {
        errors.add(new ClassFinalFieldException(element.displayName));
        return;
      }
      fields.add(field);
    }

    _registry.addType(
        element.type, new CompositeTypeMetadata(element.type, element, fields));
  }
}

/// Performs analysis where the class is annotated with custom encoder and
/// decoders.
class JsonAnalysisCustom implements Analysis {
  final SystemTypeProvider _typeProvider;
  final MetadataRegistry _registry;

  /// Creates a simple analysis instance.
  JsonAnalysisCustom(this._typeProvider, this._registry);

  @override
  final List<Exception> errors = <Exception>[];

  @override
  void analyze(ClassElement element) {
    final encoder = element.methods.firstWhere(
        (el) => el.metadata.any((ann) =>
            ann.constantValue.type.isAssignableTo(_typeProvider.jsonEncode)),
        orElse: () => null);

    if (encoder != null) {
      final decoder = element.constructors.firstWhere(
          (ctr) =>
              ctr.isFactory &&
              ctr.metadata.any((ann) => ann.constantValue.type
                  .isAssignableTo(_typeProvider.jsonDecode)),
          orElse: () => null);
      if (decoder == null) {
        errors
            .add(new Exception('Cannot define a JsonEncode annotation without '
                'a corresponding JsonDecode annotation'));
      }
      if (encoder.parameters.length != 0) {
        errors
            .add(new Exception('JsonEncode method must take zero arguments.'));
      }
      if (!encoder.returnType
          .isAssignableTo(element.context.typeProvider.objectType)) {
        errors.add(new Exception('JsonEncode method must return an Object'));
      }
      if (decoder.parameters.length != 1 ||
          !decoder.parameters.first.type
              .isAssignableTo(element.context.typeProvider.objectType)) {
        errors
            .add(new Exception('JsonDecode factory must take a single argument '
                'of type Object'));
      }

      _registry.addType(
          element.type,
          new ScalarTypeMetadata(
              element.type,
              (x) => '$x.${encoder.name}()',
              (x) => 'new ${element.name}'
                  '${decoder.name != "" ? "." : ""}'
                  '${decoder.name ?? ""}($x)'));
    } else {
      errors.add(new Exception('${element.displayName} was annotated with blah'
          ' but doesnt have a customEncode and decode blah'));
    }
  }
}
