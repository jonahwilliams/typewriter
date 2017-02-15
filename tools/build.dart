import 'package:build_runner/build_runner.dart';

import 'phases.dart';

main() async {
  await build(phases, deleteFilesByDefault: true);
}
