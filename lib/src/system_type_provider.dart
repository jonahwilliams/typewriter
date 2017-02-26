import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

/// Provides [DartType]s for the annotation elements.
class SystemTypeProvider {
  /// An annotation which tells analysis to ignore the field.
  final DartType ignore;

  /// An annotation which provides a different key name.
  final DartType jsonKey;

  /// An annotation which tells analysis to use the json builder.
  final DartType json;

  /// An annotation which switches to a custom encoder/decoder strategy.
  final DartType jsonEncode;

  /// Same as above, must be paired to work correctly.
  final DartType jsonDecode;

  /// An annotation which tells analysis to use the xml builder.
  final DartType xml;

  /// An annotation which tells analysis to override the default behavior for
  /// xml builders
  final DartType xmlElement;
  final DartType xmlAttribute;

  /// Builds a new [SystemTypeProvider] from the package:typewriter annotation library element.
  factory SystemTypeProvider(LibraryElement library) {
    return new SystemTypeProvider._(
        library.getType('Ignore').type,
        library.getType('JsonKey').type,
        library.getType('Json').type,
        library.getType('JsonEncode').type,
        library.getType('JsonDecode').type,
        library.getType('xml').type,
        library.getType('XmlElement').type,
        library.getType('XmlAttribute').type);
  }

  SystemTypeProvider._(this.ignore, this.jsonKey, this.json, this.jsonEncode,
      this.jsonDecode, this.xml, this.xmlElement, this.xmlAttribute);
}
