import 'package:build_runner/build_runner.dart';
import 'package:source_gen/source_gen.dart';
import 'package:typewriter/builder/builder.dart';


final jsonBuild = new Phase()..addAction(
    new CodecBuilder(),
    new InputSet('typewriter', const ['example/lib/codecs/codecs.dart']));

final phases = new PhaseGroup()
  ..addPhase(jsonBuild);

