import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/resolver.dart';
import 'package:code_builder/code_builder.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:resolver/resolver.dart';

import 'package:typewriter/exceptions/exceptions.dart';
import 'package:typewriter/metadata/json_description.dart';
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
      analysis = new AnalysisJsonSimple(systemProvider);
    }

    Future<Null> loadSource(String source, String name) async {
      library = await resolver.resolveSourceCode(source);
      element = library.getType(name);

      provider = element.context.typeProvider;
      systemProvider = new MockSystemTypeProvider();
      analysis = new AnalysisJsonSimple(systemProvider);
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
      final description = analysis.analyze(element, {}) as DescriptionJson;

      expect(description.name, 'Dog');
      expect(
          description.fields,
          unorderedEquals([
            new DescriptionJsonField('name', provider.stringType),
            new DescriptionJsonField('id', provider.intType),
            new DescriptionJsonField('isAlive', provider.boolType),
            new DescriptionJsonField('money', provider.doubleType),
            new DescriptionJsonField('symbol', provider.symbolType),
          ]));
    });

    test('class with @ignore public fields', () async {
      await loadSource(
          'class Ignore { const Ignore(); }\n'
          'class Dog {\n'
          '  int id;\n'
          '  @Ignore()\n'
          '  String name;\n'
          '}\n',
          'Dog');
      final description = analysis.analyze(element, {}) as DescriptionJson;

      expect(description.name, 'Dog');
      expect(description.fields,
          unorderedEquals([new DescriptionJsonField('id', provider.intType)]));
    });

    test('class with repeated public fields', () async {
      await loadClass(
          clazz('Dog', [
            new FieldBuilder('names',
                type: new TypeBuilder('List',
                    genericTypes: [new TypeBuilder('String')]))
          ]),
          'Dog');
      final description = analysis.analyze(element, {}) as DescriptionJson;

      expect(description.name, 'Dog');
      expect(description.fields, [
        new DescriptionJsonField('names', provider.stringType, repeated: true)
      ]);
    });

    test('class with final fields', () async {
      await loadClass(
          clazz('Dog', [
            new FieldBuilder.asFinal('name', type: new TypeBuilder('String'))
          ]),
          'Dog');

      try {
        analysis.analyze(element, {});
      } catch (err) {
        expect(err, new isInstanceOf<ClassFinalFieldException>());
      }
    });

    test('class with inheritance', () async {
      await loadClass(
          new ClassBuilder('DogList', asExtends: new TypeBuilder('ListBase')),
          'DogList');

      try {
        analysis.analyze(element, {});
      } catch (err) {
        expect(err, new isInstanceOf<ClassUsingExtendsKeywordException>());
      }
    });

    test('class with @JsonKey annotation', () async {
      await loadSource(
          '''
      class JsonKey {
        final String key;
        const JsonKey(this.key);
       }

       class Dog {
         @JsonKey('birth_day')
         double birthDay;
       }
      ''',
          'Dog');

      final description = analysis.analyze(element, {}) as DescriptionJson;

      expect(description.name, 'Dog');
      expect(description.fields, [
        new DescriptionJsonField('birthDay', provider.doubleType,
            key: 'birth_day')
      ]);
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
