library typewriter.analysis;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:typewriter/metadata/metadata.dart';
import 'package:typewriter/exceptions/exceptions.dart';
import 'package:typewriter/src/system_type_provider.dart';
import 'package:typewriter/metadata/json_description.dart';
import 'package:typewriter/metadata/xml_description.dart';

part 'src/json_analysis.dart';
part 'src/xml_analysis.dart';

/// Performs analysis on a [ClassElement] to determine if a valid codec can
/// be constructed.
abstract class Analysis {
  /// Analyzes the [ClassElement] to determine if.
  BuildsCodec analyze(ClassElement element, Map<DartType, Metadata> registry);
}
