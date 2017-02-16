import 'package:test/test.dart';
import 'package:typewriter/analysis/analysis.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/type_system.dart';
import 'package:analyzer/analyzer.dart';
import 'package:resolver/resolver.dart';
import 'package:analyzer/src/generated/resolver.dart' show TypeProviderImpl;

void main() {
  group('SimpleStrategy', () {
    AnalysisStrategy strategy;
    Resolver resolver;
    TypeProvider typeProvider;

    setUp(() {
      strategy = const SimpleStrategy();
      resolver = new Resolver();
      typeProvider = new TypeProviderImpl();
    });

    test('works on plain dart objects', () async {
      final source = '''
        class Foo {
          String name;
          int age;
          DateTime birthday;
        }''';
      final library = await resolver.resolveSourceCode(source);
      final element = library.getType('Foo');

      expect(strategy.analyze(element).fields, unorderedEquals([
        new FieldDescription('name', TypeProviderBase.),
        new FieldDescription('int', null),
        new FieldDescription('DateTime', null),
      ]));
    });

    test('does not work on classes with inheritance', () async {
      final source = '''
        class Bar {}

        class Foo extends Bar {
          String name;
        }
      ''';
      final library = await resolver.resolveSourceCode(source);
      final element = library.getType('Foo');

      expect(() => strategy.analyze(element), throwsException);
    });

    test('does not work on classes with final fields', () async {
      final source = '''
        class Foo {
          String name;
          final bar = 2;
        }
      ''';
      final library = await resolver.resolveSourceCode(source);
      final element = library.getType('Foo');

      expect(() => strategy.analyze(element), throwsException);
    });
  });
}
