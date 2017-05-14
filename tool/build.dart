import 'dart:async';
import 'dart:io';

import 'package:build_runner/build_runner.dart';
import 'package:typewriter/typewriter.dart';

Future main(List<String> arguments) async {
  var packageName = arguments[0];
  var directoryName = arguments[1];
  print(packageName);
  print(directoryName);
  var inputs = <String>[];
  var directory = new Directory(directoryName);
  for (var entity in directory.listSync(recursive: true)) {
    if (entity is File) {
      inputs.add(entity.path);
    }
  }
  print(inputs);
  var phase = new PhaseGroup.singleAction(
      new JsonBuilder(), new InputSet(packageName, inputs));
  await build(phase, deleteFilesByDefault: true);
}