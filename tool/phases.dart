import 'package:build_runner/build_runner.dart';
import 'package:typewriter/builder/json_builder.dart';
import 'package:typewriter/builder/xml_builder.dart';

final jsonPhases = new PhaseGroup.singleAction(new JsonBuilder(),
    new InputSet('typewriter', const ['example/lib/codecs/codecs.dart']));

final xmlPhase = new PhaseGroup.singleAction(new XmlBuilder(),
    new InputSet('typewriter', const ['example/lib/codecs/codecs.dart']));
