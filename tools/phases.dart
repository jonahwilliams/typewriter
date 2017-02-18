import 'package:build_runner/build_runner.dart';
import 'package:source_gen/source_gen.dart';

import 'package:typewriter/builders/builder.dart';
import 'package:typewriter/generators/generator.dart';
import 'package:typewriter/writer/writer.dart';
import 'package:typewriter/analysis/analysis.dart';

final PhaseGroup phases = new PhaseGroup.singleAction(
    new CodecBuilder(
      const TypewriterGenerator(
        const JsonWriter(),
        const SimpleStrategy())),
    new InputSet('typewriter', const ['example/lib/codecs/codecs.dart']));
