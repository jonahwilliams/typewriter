import 'package:test/test.dart';
import 'package:typewriter/analysis/analysis.dart';
import 'package:typewriter/descriptions/descriptions.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/type_system.dart';
import 'package:analyzer/analyzer.dart';
import 'package:resolver/resolver.dart';

void main() {
  final resolver = new Resolver();

  group('SimpleStrategy', () {
    AnalysisStrategy strategy;

    setUp(() {
      strategy = const SimpleStrategy();
    });

    test('works on plain dart objects', () async {
      const source = '''
        class Foo {
          String name;
          int age;
          DateTime birthday;
        }''';
      final library = await resolver.resolveSourceCode(source);
      final element = library.getType('Foo');

      expect(
          strategy.analyze(element, element.context).fields,
          unorderedEquals([
            new SimpleDescription('name', element.getField('name').type),
            new SimpleDescription('age', element.getField('age').type),
            new SimpleDescription(
                'birthday', element.getField('birthday').type),
          ]));
    });

    test('does not work on classes with inheritance', () async {
      const source = '''
        class Bar {}

        class Foo extends Bar {
          String name;
        }
      ''';
      final library = await resolver.resolveSourceCode(source);
      final element = library.getType('Foo');

      expect(() => strategy.analyze(element, element.context), throwsException);
    });

    test('does not work on classes with final fields', () async {
      const source = '''
        class Foo {
          String name;
          final bar = 2;
        }
      ''';
      final library = await resolver.resolveSourceCode(source);
      final element = library.getType('Foo');

      expect(() => strategy.analyze(element, element.context), throwsException);
    });

    // TODO: what is it called when you leave off the ctr?
    test('does not work on classes with an unnamed non-default construtor',
        () async {
      const source = '''
        class Bar {
          int fizz;

          Bar(this.fizz);
        }
      ''';
      final library = await resolver.resolveSourceCode(source);
      final element = library.getType('Bar');

      expect(() => strategy.analyze(element, element.context), throwsException);
    });

    test('does allow extra alternative constructors', () async {
      const source = '''
        class Fizz {
          int foo;

          Fizz.alternative(this.foo);
        }
      ''';
      final library = await resolver.resolveSourceCode(source);
      final element = library.getType('Fizz');

      expect(strategy.analyze(element, element.context).fields,
          [new SimpleDescription('foo', element.getField('foo').type)]);
    });
  });
}
