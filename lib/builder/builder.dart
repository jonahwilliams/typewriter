import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/src/dart_formatter.dart';
import 'package:typewriter/src/codec_builder.dart';
import 'package:typewriter/src/metadata.dart';
import 'package:typewriter/src/system_type_provider.dart';

AssetId _generatedFile(AssetId input) => input.changeExtension('.g.dart');

///
class CodecAnalyzerStep implements Builder {
  MetadataRegistry _registry;
  SystemTypeProvider _typeProvider;

  ///
  CodecAnalyzerStep();

  @override
  Future<Null> build(BuildStep step) async {
    final resolver = await step.resolver;
    if (!resolver.isLibrary(step.inputId)) {
      return;
    }
    final coreLib = resolver.getLibraryByName('dart.core');
    final typewriterLib = resolver.getLibraryByName('typewriter.annotations');
    _typeProvider = new SystemTypeProviderImpl(typewriterLib);

    final library = resolver.getLibrary(step.inputId);
    _registry = new MetadataRegistryImpl(library.context, coreLib);
    log.config('Initializing metadata map');

    for (final element in _getClassElements(library)) {
      try {
        _analyze(element);
      } on Exception catch (err) {
        log.severe(err);
      }
    }

    final contentBuffer = new StringBuffer();
    contentBuffer.writeln("part of ${library.displayName};");
    contentBuffer.writeln('const jsonCodec = const JsonCodec();');

    for (final metadata in _registry.compositeTypes) {
      contentBuffer.write(_generate(metadata.element));
    }

    final result = contentBuffer.toString();
    final formatter = new DartFormatter();

    await step.writeAsString(
        _generatedFile(step.inputId), formatter.format(result));
  }

  @override
  List<AssetId> declareOutputs(AssetId assetId) => [_generatedFile(assetId)];

  void _analyze(ClassElement element) {
    if (element.supertype.displayName != 'Object') {
      throw new Exception('Cannot use ${element.name} because it uses '
          'inheritance or mixins.');
    }
    // Encoder/Decoder strategy adds the type as a Scalar instead of creating
    // a Codec.
    final encoder = element.methods.firstWhere(
        (el) => el.metadata.any((ann) =>
            ann.constantValue.type.isAssignableTo(_typeProvider.jsonEncoder)),
        orElse: () => null);
    if (encoder != null) {
      final decoder = element.constructors.firstWhere(
          (ctr) =>
              ctr.isFactory &&
              ctr.metadata.any((ann) => ann.constantValue.type
                  .isAssignableTo(_typeProvider.jsonDecoder)),
          orElse: () => null);
      if (decoder == null) {
        throw new Exception('Cannot define a JsonEncode annotation without '
            'a corresponding JsonDecode annotation');
      }
      // Oh yeah type checking.
      if (encoder.parameters.length != 0) {
        throw new Exception('JsonEncode method must take zero arguments.');
      }
      if (!encoder.returnType
          .isAssignableTo(element.context.typeProvider.objectType)) {
        throw new Exception('JsonEncode method must return an Object');
      }
      if (decoder.parameters.length != 1 ||
          !decoder.parameters.first.type
              .isAssignableTo(element.context.typeProvider.objectType)) {
        throw new Exception('JsonDecode factory must take a single argument '
            'of type Object');
      }

      _registry.addType(
          element.type,
          new ScalarTypeMetadata(
              element.type,
              (x) => '$x.${encoder.name}()',
              (x) => 'new ${element.name}'
                  '${decoder.name != "" ? "." : ""}'
                  '${decoder.name ?? ""}($x)'));
      return;
    }

    if (element.unnamedConstructor?.isDefaultConstructor == null) {
      throw new Exception('Cannot use ${element.name} because it has no '
          'default constructor.');
    }
    _registry.addType(
        element.type, new CompositeTypeMetadata(element.type, element));

    loop:
    for (final field in element.fields) {
      if (field.isFinal) {
        throw new Exception('Cannot use ${element.name} because it has final '
            'fields');
      }
      if (field.isPublic) {
        for (final annotation in field.metadata) {
          final value = annotation.constantValue;
          if (value.type.isAssignableTo(_typeProvider.ignore)) {
            continue loop;
          }
        }
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
        if (value.type.isAssignableTo(_typeProvider.ignore)) {
          continue loop;
        }
        if (value.type.isAssignableTo(_typeProvider.jsonKey)) {
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
        .map((dec) => (dec as ClassDeclaration).element)
        .where((el) => el.metadata.any(
            (an) => an.constantValue.type.isAssignableTo(_typeProvider.json)));
  }
}
