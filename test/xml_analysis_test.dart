import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/resolver.dart';
import 'package:code_builder/code_builder.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:resolver/resolver.dart';

import 'package:typewriter/metadata/xml_description.dart';
import 'package:typewriter/analysis/analysis.dart';
import 'package:typewriter/src/system_type_provider.dart';

void main() {
  group('Analysis', () {
    final resolver = new Resolver();
    LibraryElement library;
    ClassElement element;
    TypeProvider provider;
    MockSystemTypeProvider systemProvider;
    Analysis analysis;

    Future<Null> loadClass(ClassBuilder builder, String name) async {
      final source = builder.buildClass().toSource();
      library = await resolver.resolveSourceCode(source);

      element = library.getType(name);
      provider = element.context.typeProvider;
      systemProvider = new MockSystemTypeProvider();
      analysis = new AnalysisXmlSimple(systemProvider);
    }

    test('class with only public fields', () async {
      final builder = clazz('Dog', [
        new FieldBuilder('name', type: new TypeBuilder('String')),
        new FieldBuilder('id', type: new TypeBuilder('int')),
        new FieldBuilder('isAlive', type: new TypeBuilder('bool')),
        new FieldBuilder('money', type: new TypeBuilder('double')),
        new FieldBuilder('symbol', type: new TypeBuilder('Symbol')),
      ]);
      await loadClass(builder, 'Dog');
      final description = analysis.analyze(element, {}) as DescriptionXml;

      expect(
          description,
          new DescriptionXml('Dog', elements: [
            new DescriptionXmlElement('name', provider.stringType),
            new DescriptionXmlElement('id', provider.intType),
            new DescriptionXmlElement('isAlive', provider.boolType),
            new DescriptionXmlElement('money', provider.doubleType),
            new DescriptionXmlElement('symbol', provider.symbolType)
          ]));
    });
  });
}

class MockSystemTypeProvider extends Mock implements SystemTypeProvider {
  @override
  bool isIgnore(DartType type) => type.displayName == 'Ignore';

  @override
  bool isPropertyJson(DartType type) => type.displayName == 'JsonKey';
}

class MockType extends Mock implements DartType {}
