import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:typewriter/analysis/analysis.dart';
import 'package:typewriter/metadata/metadata.dart';
import 'package:typewriter/src/system_type_provider.dart';
import 'package:code_builder/code_builder.dart';

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
      ..addMembers([
        _xmlEncoder,
        _xmlDecoder,
        _xmlCodec,
      ])
      ..addMembers(codecs.map((codec) => codec.buildEncoder(_registry)))
      ..addMembers(codecs.map((codec) => codec.buildDecoder(_registry)))
      ..addMembers(codecs.map((codec) => codec.buildCodec(_registry)))
      ..addMembers(codecs.map((codec) => _fuseCodec(codec.name)));

    await step.writeAsString(
        _generatedFile(step.inputId), prettyToSource(result.buildAst()));
  }

  void _initialize(LibraryElement coreLib, LibraryElement typewriterLib) {
    _typeProvider = new SystemTypeProvider(typewriterLib);
    _registry = buildXmlRegistry(coreLib);
    _analysis = new AnalysisXmlSimple(_typeProvider);
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
            .any((an) => _typeProvider.isXml(an.constantValue.type)));
  }

  AssetId _generatedFile(AssetId input) => input.changeExtension('.xml.g.dart');

  StatementBuilder _fuseCodec(String name) =>
      reference('${name}Codec').newInstance([]).invoke('fuse', [
        reference('_XmlCodec').newInstance([])
      ]).asFinal(
          '${name.toLowerCase()}XmlCodec',
          new TypeBuilder('Codec', genericTypes: [
            new TypeBuilder(name),
            new TypeBuilder('String'),
          ]));

  static final StatementBuilder _xmlCodec = new ClassBuilder('_XmlCodec',
      asExtends: new TypeBuilder('Codec', genericTypes: [
        new TypeBuilder('XmlNode'),
        new TypeBuilder('String'),
      ]))
    ..addMethod(new MethodBuilder.getter('encoder',
        returnType: new TypeBuilder('Converter', genericTypes: [
          new TypeBuilder('XmlNode'),
          new TypeBuilder('String'),
        ]),
        returns: reference('_XmlEncoder').newInstance([])))
    ..addMethod(new MethodBuilder.getter('decoder',
        returnType: new TypeBuilder('Converter', genericTypes: [
          new TypeBuilder('String'),
          new TypeBuilder('XmlNode'),
        ]),
        returns: reference('_XmlDecoder').newInstance([])));

  static final StatementBuilder _xmlEncoder = new ClassBuilder('_XmlEncoder',
      asExtends: new TypeBuilder('Converter', genericTypes: [
        new TypeBuilder('XmlNode'),
        new TypeBuilder('String'),
      ]))
    ..addMethod(
        new MethodBuilder('convert', returnType: new TypeBuilder('String'))
          ..addPositional(
              new ParameterBuilder('input', type: new TypeBuilder('XmlNode')))
          ..addStatement(reference('XmlProcessing').newInstance(
              [literal('xml'), literal('version="1.0"')]).asFinal('processing'))
          ..addStatement(reference('XmlDocument').newInstance([
            list([reference('processing'), reference('input')])
          ]).invoke('toString', const []).asReturn()));

  static final StatementBuilder _xmlDecoder = new ClassBuilder('_XmlDecoder',
      asExtends: new TypeBuilder('Converter', genericTypes: [
        new TypeBuilder('String'),
        new TypeBuilder('XmlNode'),
      ]))
    ..addMethod(
        new MethodBuilder('convert', returnType: new TypeBuilder('XmlNode'))
          ..addPositional(
              new ParameterBuilder('input', type: new TypeBuilder('String')))
          ..addStatement(reference('parse')
              .call([reference('input')])
              .property('rootElement')
              .asReturn()));
}
