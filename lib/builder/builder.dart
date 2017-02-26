import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:typewriter/analysis/analysis.dart';
import 'package:typewriter/metadata/metadata.dart';
import 'package:typewriter/src/system_type_provider.dart';
import 'package:dart_style/src/dart_formatter.dart';

final dartFormatter = new DartFormatter();


AssetId _generatedFile(AssetId input) => input.changeExtension('.g.dart');


class CodecBuilder implements Builder {
  Analysis _jsonSimple;
  Analysis _xmlSimple;
  SystemTypeProvider _typeProvider;
  Map<DartType, Metadata> _jsonRegistry;
  Map<DartType, Metadata> _xmlRegistry;

  CodecBuilder();

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

    // TODO: refactor decision into separate class.
    for (final element in _getClassElements(library)) {
      final jsonAnnotation = element.metadata.firstWhere(
              (an) => an.constantValue.type.isAssignableTo(_typeProvider.json),
          orElse: () => null);
//      final xmlAnnotation = element.metadata.firstWhere(
//              (an) => an.constantValue.type.isAssignableTo(_typeProvider.xml),
//          orElse: () => null);
      if (jsonAnnotation != null) {
//        final customCodec = jsonAnnotation.constantValue
//            .getField('useCustomCodec')
//            .toBoolValue();
          codecs.add(_jsonSimple.analyze(element, _jsonRegistry));
      }
//      if (xmlAnnotation != null) {
//          codecs.add(_xmlSimple.analyze(element, _xmlRegistry));
//      }
    }

    final contentBuffer = new StringBuffer();
    contentBuffer.writeln("part of ${library.displayName};");

    for (final codec in codecs) {
      contentBuffer.write(codec.buildEncoder(_jsonRegistry).buildClass().toSource());
      contentBuffer.write(codec.buildDecoder(_jsonRegistry).buildClass().toSource());
      contentBuffer.write(codec.buildCodec(_jsonRegistry).buildClass().toSource());
    }


    final result = dartFormatter.format(contentBuffer.toString());


    await step.writeAsString(
        _generatedFile(step.inputId), result);
  }

  @override
  List<AssetId> declareOutputs(AssetId assetId) => [_generatedFile(assetId)];

  void _initialize(LibraryElement coreLib, LibraryElement typewriterLib) {
    _typeProvider = new SystemTypeProvider(typewriterLib);
    _jsonRegistry = buildJsonRegistry(coreLib);
    _jsonSimple = new JsonAnalysisSimple(_typeProvider);
  }

  /// TODO: refactor to grab any class with library specific class annotation
  Iterable<ClassElement> _getClassElements(LibraryElement unit) {
    final classes = unit.units.expand((unit) => unit.unit.declarations)
        .where((dec) => dec is ClassDeclaration)
        .map((dec) => (dec as ClassDeclaration).element)
        .where((el) =>
        el.metadata.any(
            (an) =>
                an.constantValue.type.isAssignableTo(_typeProvider.json)));
    final importedClasses = unit.importedLibraries
        .where((lib) => !lib.isDartCore && !lib.isInSdk)
        .expand((el) => el.units.expand((unit) => unit.unit.declarations))
        .where((dec) => dec is ClassDeclaration)
        .map((dec) => (dec as ClassDeclaration).element)
        .where((el) =>
        el.metadata.any(
                (an) =>
                an.constantValue.type.isAssignableTo(_typeProvider.json)));

    return <ClassElement>[]
        ..addAll(classes)
        ..addAll(importedClasses);
  }
}
