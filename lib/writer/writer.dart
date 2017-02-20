library typewriter.writer;

import '../analysis/analysis.dart';
import '../descriptions/descriptions.dart';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';
import 'package:resolver/src/analyzer.dart';

part 'src/json_writer.dart';
part 'src/xml_writer.dart';
part 'src/yaml_writer.dart';

/// Converts the [ClassDescription] from analysis into a codec.
///
/// TODO: take platform destination into consideration.
/// TODO: massive hack.
abstract class Writer {
  const Writer();

  String write(ClassDescription description, AnalysisContext context);
}
