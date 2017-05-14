import 'package:build_runner/build_runner.dart';
import 'package:typewriter/typewriter.dart';

final jsonPhase = new PhaseGroup.singleAction(new JsonBuilder(),
    new InputSet('typewriter', const ['example/lib/codecs/codecs.dart']));

final xmlPhase = new PhaseGroup.singleAction(new XmlBuilder(),
    new InputSet('typewriter', const ['example/lib/codecs/codecs.dart']));
