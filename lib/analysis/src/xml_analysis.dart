part of typewriter.analysis;

class AnalysisXmlSimple implements Analysis {
  final SystemTypeProvider _typeProvider;

  /// Creates a simple analysis instance.
  AnalysisXmlSimple(this._typeProvider);

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
    final fields = <DescriptionXmlElement>[];
    for (final field in element.fields) {
      if (field.metadata
          .any((an) => _typeProvider.isIgnore(an.constantValue.type))) {
        continue;
      }
      if (field.isFinal) {
        throw new ClassFinalFieldException(element.displayName);
      }
//      final keyAnnotation = field.metadata.firstWhere(
//              (annotation) => annotation.constantValue.type
//              .isAssignableTo(_typeProvider),
//          orElse: () => null);
//      final key = keyAnnotation != null
//          ? keyAnnotation.constantValue.getField('key')
//          : field.name;
//      if (field.type.displayName.contains('List')) {
//        fields.add(new JsonFieldDescription(key, field.name, true,
//            (field.type as ParameterizedType).typeArguments.first));
//      } else {
      fields.add(new DescriptionXmlElement(field.name, field.type));
    }
    registry[element.type] = new Metadata.composite(element.name);

    return new DescriptionXml(element.displayName, elements: fields);
  }
}
