library typewriter.annotations;

import 'package:meta/meta.dart';

part 'src/json_annotations.dart';
part 'src/xml_annotations.dart';

/// Basic information that can be provided on a field or constructor argument.
abstract class DataAnnotation {
  ///
  String get key;

  ///
  int get position;
}

/// Basic information that can be added onto a class/
abstract class ClassAnnotation {}

/// An override for a factory function which replaces the default decoder.
abstract class DecodeAnnotation {}

/// An override for a method which replaces the default encoder.
abstract class EncodeAnnotation {}

/// Ignores the field when generating codecs.
class Ignore {
  ///
  const Ignore();
}
