import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/resolver.dart';
import 'package:code_builder/code_builder.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:resolver/resolver.dart';

import 'package:typewriter/metadata/metadata.dart';
import 'package:typewriter/metadata/json_description.dart';
import 'package:typewriter/analysis/analysis.dart';
import 'package:typewriter/src/system_type_provider.dart';

void main() {
  group('Analysis', () {
    Resolver resolver = new Resolver();
    LibraryElement library;
    ClassElement element;
    TypeProvider provider;
    Analysis analysis;

    Future<Null> loadClass(ClassBuilder builder, String name) async {
      final source = builder.buildClass().toSource();
      library = await resolver.resolveSourceCode(source);
      element = library.getType(name);
      provider = element.context.typeProvider;
      analysis = new JsonAnalysisSimple(new MockTypeProvider());
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
      final description = analysis.analyze(element, {}) as JsonDescription;

      expect(description.name, 'Dog');
      expect(
          description.fields,
          unorderedEquals([
            new JsonFieldDescription('name', provider.stringType),
            new JsonFieldDescription('id', provider.intType),
            new JsonFieldDescription('isAlive', provider.boolType),
            new JsonFieldDescription('money', provider.doubleType),
            new JsonFieldDescription('symbol', provider.symbolType),
          ]));
    });

    test('class with @ignore public fields', () {});

    test('class with repeated public fields', () {});

    test('class with final fields', () {});

    test('class with inheritance', () {});

    test('class with @JsonKey annotation', () {});
  });
}


class MockTypeProvider extends Mock implements SystemTypeProvider {}
