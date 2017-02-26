import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

/// Provides [DartType]s for the annotation elements.
class SystemTypeProvider {
  /// An annotation which tells analysis to ignore the field.
  final DartType _ignore;

  /// An annotation which provides a different key name.
  final DartType _jsonKey;

  /// An annotation which tells analysis to use the json builder.
  final DartType _json;

  /// An annotation which switches to a custom encoder/decoder strategy.
  final DartType _jsonEncode;

  /// Same as above, must be paired to work correctly.
  final DartType _jsonDecode;

  /// An annotation which tells analysis to use the xml builder.
  final DartType _xml;

  /// An annotation which tells analysis to override the default behavior for
  /// xml builders
  final DartType _xmlElement;
  final DartType _xmlAttribute;

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

  SystemTypeProvider._(
      this._ignore,
      this._jsonKey,
      this._json,
      this._jsonEncode,
      this._jsonDecode,
      this._xml,
      this._xmlElement,
      this._xmlAttribute);

  bool isIgnore(DartType type) => type.isAssignableTo(_json);
  bool isJsonKey(DartType type) => type.isAssignableTo(_jsonKey);
  bool isJson(DartType type) => type.isAssignableTo(_json);
  bool isJsonEncode(DartType type) => type.isAssignableTo(_jsonDecode);
  bool isJsonDecode(DartType type) => type.isAssignableTo(_jsonEncode);
  bool isXml(DartType type) => type.isAssignableTo(_xml);
  bool isXmlElement(DartType type) => type.isAssignableTo(_xmlElement);
  bool isXmlAttribute(DartType type) => type.isAssignableTo(_xmlAttribute);
}
