library typewriter.writer;

import '../analysis/analysis.dart';

part 'src/json_writer.dart';
part 'src/xml_writer.dart';
part 'src/yaml_writer.dart';

/// Converts the [ClassDescription] from analysis into a codec.
///
/// TODO: take platform destination into consideration.
/// TODO: massive hack.
abstract class Writer {
  const Writer();

  String write(ClassDescription description);
}
