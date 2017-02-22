import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/src/dart_formatter.dart';

import '../analysis/analysis.dart';

class CodecAnalyzerStep implements Builder {
  final MetadataRegistry _registry;
  TypewriterTypeProvider _typeProvider;

  CodecAnalyzerStep(this._registry);

  Future<Null> build(BuildStep step) async {
    final resolver = await step.resolver;
    if (!resolver.isLibrary(step.inputId)) {
      return;
    }
    final coreLib = resolver.getLibraryByName('dart.core');
    final typewriterLib = resolver.getLibraryByName('typewriter.annotations');
    print(typewriterLib);
    _typeProvider = new TypewriterTypeProvider(typewriterLib);

    final library = resolver.getLibrary(step.inputId);
    _registry.initialize(library.context, coreLib);
    log.config('Initializing metadata map');

    for (final element in _getClassElements(library)) {
      try {
        _analyze(element);
      } on Exception catch (err) {
        log.severe(err);
      }
      log.config('${_registry.metadata}');
    }

    final contentBuffer = new StringBuffer();
    contentBuffer.writeln("part of ${library.displayName};");
    contentBuffer.writeln('const jsonCodec = const JsonCodec();');

    for (final metadata in _registry.metadata.values) {
      if (metadata is CompositeTypeMetadata) {
        contentBuffer.write(_generate(metadata.element));
      }
    }

    final result = contentBuffer.toString();
    final formatter = new DartFormatter();

    await step.writeAsString(
        _generatedFile(step.inputId), formatter.format(result));
  }

  List<AssetId> declareOutputs(AssetId assetId) => [_generatedFile(assetId)];

  void _analyze(ClassElement element) {
    if (_registry.metadata.containsKey(element.type)) {
      throw new Exception('${element.displayName} has already been defined');
    }

    if (element.supertype.displayName != 'Object') {
      throw new Exception('Cannot use ${element.name} because it uses '
          'inheritance or mixins.');
    }

    if (!(element.unnamedConstructor?.isDefaultConstructor ?? true)) {
      throw new Exception('Cannot use ${element.name} because it has no '
          'default constructor.');
    }
    _registry.metadata[element.type] =
        new CompositeTypeMetadata(element.type, element);

    loop:
    for (final field in element.fields) {
      if (field.isFinal) {
        throw new Exception('Cannot use ${element.name} because it has final '
            'fields');
      }
      if (field.isPublic) {
        for (final annotation in field.metadata) {
          final value = annotation.constantValue;
          if (value.type.isAssignableTo(_typeProvider.ignoreType)) {
            continue loop;
          }
        }
      }
      if (_registry.metadata[field.type] == null) {
        _registry.missing.add(field.type);
      }
    }
  }

  String _generate(ClassElement element) {
    final builder = new CodecBuilder.Json(_registry, element.type);

    loop:
    for (final field in element.fields.where((x) => x.isPublic)) {
      String key = field.name;
      int position = -1;
      for (final annotation in field.metadata) {
        final value = annotation.constantValue;
        if (value.type.isAssignableTo(_typeProvider.ignoreType)) {
          continue loop;
        }
        if (value.type.isAssignableTo(_typeProvider.jsonKeyType)) {
          key = annotation.constantValue.getField('key').toStringValue();
          position = annotation.constantValue.getField('position').toIntValue();
        }
      }
      // Temp hack because type APIs did not work as I imagined.
      if (field.type.displayName.contains('List')) {
        final el = (field.type as ParameterizedType).typeArguments.first;
        builder.addField(field.name, el, true, key, position);
      } else {
        builder.addField(field.name, field.type, false, key, position);
      }
    }

    return builder.build();
  }

  Iterable<ClassElement> _getClassElements(LibraryElement unit) {
    return unit.importedLibraries
        .where((lib) => !lib.isDartCore && !lib.isInSdk)
        .expand((el) => el.units.expand((unit) => unit.unit.declarations))
        .where((dec) => dec is ClassDeclaration)
        .map((dec) => (dec as ClassDeclaration).element);
  }
}

AssetId _generatedFile(AssetId input) => input.changeExtension('.g.dart');
