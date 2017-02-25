part of typewriter.analysis;

class XmlSimpleAnalysis implements Analysis {
  final SystemTypeProvider _typeProvider;
  final MetadataRegistry _registry;

  @override
  final List<Exception> errors = [];

  /// Creates a simple analysis instance.
  XmlSimpleAnalysis(this._typeProvider, this._registry);

  @override
  void analyze(ClassElement element) {
    // May not use inheritance
    if (!element.supertype.isObject) {
      errors.add(new ClassUsingExtendsKeywordException(element.displayName));
      return;
    }
  }
}