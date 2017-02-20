import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/src/dart_formatter.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:typewriter/generators/generator.dart';

class CodecBuilder implements Builder {
  final TypewriterGenerator _generator;

  const CodecBuilder(this._generator);

  Future<Null> build(BuildStep step) async {
    final resolver = await step.resolver;
    if (!resolver.isLibrary(step.inputId)) {
      return;
    }
    final library = resolver.getLibrary(step.inputId);
    final contentBuffer = new StringBuffer();

    contentBuffer.writeln("part of ${library.displayName};");

    contentBuffer.writeln('const jsonCodec = const JsonCodec();');

    for (final element in _getClassElements(library)) {
      log.fine('Generating codec for ${element.displayName}');
      final createdUnit = await _generator.generate(element, step);
      contentBuffer.write(createdUnit);
    }

    final result = contentBuffer.toString();
    final formatter = new DartFormatter();

    await step.writeAsString(
        _generatedFile(step.inputId), formatter.format(result));
  }

  List<AssetId> declareOutputs(AssetId assetId) => [_generatedFile(assetId)];

  Iterable<ClassElement> _getClassElements(LibraryElement unit) sync* {
    print(unit);
    for (final z in unit.importedLibraries) {
      if (!z.isDartCore && !z.isInSdk) {
        for (final x in z.units) {
          for (final y in x.unit.declarations) {
            if (y is ClassDeclaration) {
              yield y.element;
            }
          }
        }
      }
    }
  }

  AssetId _generatedFile(AssetId input) => input.changeExtension('.g.dart');
}
