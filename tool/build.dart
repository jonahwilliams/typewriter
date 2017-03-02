import 'package:build_runner/build_runner.dart';

import 'phases.dart';

main() async {
  await build(jsonPhase, deleteFilesByDefault: false);
  await build(xmlPhase, deleteFilesByDefault: false);
}
