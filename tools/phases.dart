import 'package:build_runner/build_runner.dart';
import 'package:source_gen/source_gen.dart';

import 'package:typewriter/generators/generator.dart';
import 'package:typewriter/writer/writer.dart';
import 'package:typewriter/analysis/analysis.dart';

final PhaseGroup phases = new PhaseGroup.singleAction(
    new GeneratorBuilder(const [
      const TypewriterGenerator(
        const XmlWriter(),
        const SimpleStrategy())]),
    new InputSet('typewriter', const ['example/*.dart']));
