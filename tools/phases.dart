import 'package:build_runner/build_runner.dart';
import 'package:source_gen/source_gen.dart';

import 'package:typewriter/generators/generator.dart';

final PhaseGroup phases = new PhaseGroup.singleAction(
    new GeneratorBuilder(const [const TypewriterGenerator()]),
    new InputSet('typewriter', const ['example/*.dart']));
