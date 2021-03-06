import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';

import 'analysis.dart';
import 'metadata.dart';
import 'system_type_provider.dart';

/// [Builder] which generates JSON codecs.
class JsonBuilder implements Builder {
  SystemTypeProvider _typeProvider;
  Map<DartType, Metadata> _registry;
  Analysis _analysis;

  @override
  List<AssetId> declareOutputs(AssetId assetId) => [_generatedFile(assetId)];

  @override
  Future<Null> build(BuildStep step) async {
    var resolver = await step.resolver;
    if (!resolver.isLibrary(step.inputId)) {
      return;
    }
    _initialize(resolver.getLibraryByName('dart.core'),
        resolver.getLibraryByName('typewriter.annotations'));

    var library = resolver.getLibrary(step.inputId);
    var codecs = <BuildsCodec>[];
    for (final element in _getClassElements(library)) {
      codecs.add(_analysis.analyze(element, _registry));
    }

    final result = new PartBuilder(library.name)
      ..addMembers(codecs.map((codec) => codec.buildEncoder(_registry)))
      ..addMembers(codecs.map((codec) => codec.buildDecoder(_registry)))
      ..addMembers(codecs.map((codec) => codec.buildCodec(_registry)));

    await step.writeAsString(
        _generatedFile(step.inputId), prettyToSource(result.buildAst()));
  }

  void _initialize(LibraryElement coreLib, LibraryElement typewriterLib) {
    _typeProvider = new SystemTypeProvider(typewriterLib);
    _registry = buildJsonRegistry(coreLib);
    _analysis = new JsonAnalysis(_typeProvider);
  }

  Iterable<ClassElement> _getClassElements(LibraryElement unit) {
    var declarations = <Declaration>[]
      ..addAll(unit.units.expand((unit) => unit.unit.declarations))
      ..addAll(unit.importedLibraries
          .where((lib) => !lib.isDartCore && !lib.isInSdk)
          .expand((el) => el.units.expand((unit) => unit.unit.declarations)));

    return declarations
        .where((dec) => dec is ClassDeclaration)
        .map((dec) => (dec as ClassDeclaration).element)
        .where((el) => el.metadata
            .any((an) => _typeProvider.isDeriveJson(an.constantValue.type)));
  }

  AssetId _generatedFile(AssetId input) =>
      input.changeExtension('.json.g.dart');
}

/// [Builder] which generates XML codecs.
class XmlBuilder implements Builder {
  SystemTypeProvider _typeProvider;
  Map<DartType, Metadata> _registry;
  Analysis _analysis;

  @override
  List<AssetId> declareOutputs(AssetId assetId) => [_generatedFile(assetId)];

  @override
  Future<Null> build(BuildStep step) async {
    final resolver = await step.resolver;
    if (!resolver.isLibrary(step.inputId)) {
      return;
    }
    _initialize(resolver.getLibraryByName('dart.core'),
        resolver.getLibraryByName('typewriter.annotations'));

    final library = resolver.getLibrary(step.inputId);
    final codecs = <BuildsCodec>[];

    for (final element in _getClassElements(library)) {
      codecs.add(_analysis.analyze(element, _registry));
    }

    final result = new PartBuilder(library.name)
      ..addMembers(codecs.map((codec) => codec.buildEncoder(_registry)))
      ..addMembers(codecs.map((codec) => codec.buildDecoder(_registry)))
      ..addMembers(codecs.map((codec) => codec.buildCodec(_registry)));

    await step.writeAsString(
        _generatedFile(step.inputId), prettyToSource(result.buildAst()));
  }

  void _initialize(LibraryElement coreLib, LibraryElement typewriterLib) {
    _typeProvider = new SystemTypeProvider(typewriterLib);
    _registry = buildXmlRegistry(coreLib);
    _analysis = new XmlAnalysis(_typeProvider);
  }

  /// TODO: refactor to grab any class with library specific class annotation
  Iterable<ClassElement> _getClassElements(LibraryElement unit) {
    final declarations = <Declaration>[]
      ..addAll(unit.units.expand((unit) => unit.unit.declarations))
      ..addAll(unit.importedLibraries
          .where((lib) => !lib.isDartCore && !lib.isInSdk)
          .expand((el) => el.units.expand((unit) => unit.unit.declarations)));

    return declarations
        .where((dec) => dec is ClassDeclaration)
        .map((dec) => (dec as ClassDeclaration).element)
        .where((el) => el.metadata
            .any((an) => _typeProvider.isDeriveXml(an.constantValue.type)));
  }

  AssetId _generatedFile(AssetId input) => input.changeExtension('.xml.g.dart');
}
