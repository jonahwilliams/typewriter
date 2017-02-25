import 'dart:io';
import 'dart:async';

import 'package:test/test.dart';
import 'package:build_runner/build_runner.dart';
import 'package:typewriter/builder/builder.dart';

class Result {
  final String name;
  final List<String> golden;
  final List<String> production;

  const Result(this.name, this.golden, this.production);
}


Future<Result> testGolden(String name) async {
  final phase = new PhaseGroup.singleAction(new CodecBuilder(),
      new InputSet('typewriter', ['test/goldens/$name.dart']));
  await build(phase, deleteFilesByDefault: true);

  final golden =
      await new File('test/goldens/$name.dart.golden').readAsLines();
  final production =
      await new File('test/goldens/$name.g.dart').readAsLines();

  return new Result(name, golden, production);
}


const List<String> goldens = const [
  'test_a',
  'test_b',
];

Future<Null> main() async {
  group('goldens', () {
    test('test_a', () async {
      final result = await testGolden('test_a');
      expect(result.production, result.golden);
    });

    test('test_b', () async {
      final result = await testGolden('test_b');
      expect(result.production, result.golden);
    });

    tearDown(() async {
      goldens.forEach((name) {
        try {
          new File('test/goldens/$name.g.dart').deleteSync();
        } catch (_) {}
      });
    });
  });
}
