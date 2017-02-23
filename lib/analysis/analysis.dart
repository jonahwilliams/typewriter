library typewriter.analysis;

import 'package:analyzer/dart/element/element.dart';
import 'package:typewriter/src/metadata.dart';
import 'package:typewriter/exceptions/exceptions.dart';
import 'package:typewriter/src/system_type_provider.dart';

part 'src/json_analysis.dart';

/// Performs analysis on a [ClassElement] to determine if a valid codec can
/// be constructed.
///
/// Exceptions are stored as data.
/// Saves type information in the [MetadataRegistry].
abstract class Analysis {

  /// Analyzes the [ClassElement] to determine if.
  void analyze(MetadataRegistry registry, ClassElement element);

  /// Returns the errors generated during class analysis.
  List<Exception> get errors;
}
