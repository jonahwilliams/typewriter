import 'package:test/test.dart';
import 'package:typewriter/analysis/analysis.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/analyzer.dart';


// TODO: a better way to get `DartTypes` since this only works
// for the built in types.
DartType getDartType(String typeName) {
  final raw = '$typeName foo';
  final unit = parseCompilationUnit(raw).declarations.first;
  return unit.variables.type;
}

DartType stringType = getDartType('String');
DartType boolType = getDartType('bool');
DartType doubleType = getDartType('double');
DartType intType = getDartType('intType');
DartType dateTimeType = getDartType('DartType');


void main() {
  group('SimpleStrategy', () {
    AnalysisStrategy strategy;

    setUp(() {
      strategy = const SimpleStrategy();
    });

    test('works on plain dart objects', () {
      final source = '''
        class Foo {
          String name;
          int age;
          DateTime birthday;
        }
      ''';
      final ast = parseCompilationUnit(source);
      final element = (ast.declarations.first as ClassDeclaration).element;

      expect(strategy.analyze(element).fields, unorderedEquals([
        new FieldDescription('name', stringType),
        new FieldDescription('int', intType),
        new FieldDescription('DateTime', dateTimeType),
      ]));
    });

    test('doesnt work on classes with inheritance', () {
      final source = '''
        class Bar {}

        class Foo extends Bar {
          String name;
        }
      ''';
      final ast = parseCompilationUnit(source);
      final element = (ast.declarations.skip(1).first as ClassDeclaration).element;

      expect(strategy.analyze(element), throwsException);
    });

    test('doesnt work on classes with final fields', () {
      final source = '''
        class Foo {
          String name;
          final bar = 2;
        }
      ''';

      final ast = parseCompilationUnit(source);
      final element = (ast.declarations.first as ClassDeclaration).element;

      expect(strategy.analyze(element), throwsException);
    });

  });
}
