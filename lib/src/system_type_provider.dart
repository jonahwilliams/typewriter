import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

/// Provides [DartType]s for the annotation elements.
class SystemTypeProvider {
  /// An annotation which tells analysis to ignore the field.
  final DartType _ignore;

  /// An annotation which provides a different key name.
  final DartType _propertyJson;

  /// An annotation which tells analysis to use the json builder.
  final DartType _json;

  /// An annotation which switches to a custom encoder/decoder strategy.
  final DartType _encodeJson;

  /// Same as above, must be paired to work correctly.
  final DartType _decodeJson;

  /// An annotation which tells analysis to use the xml builder.
  final DartType _xml;

  /// An annotation which tells analysis to override the default behavior for
  /// xml builders
  final DartType _elementXml;
  final DartType _attributeXml;

  /// Builds a new [SystemTypeProvider] from the package:typewriter
  /// annotation library element.
  factory SystemTypeProvider(LibraryElement library) {
    return new SystemTypeProvider._(
        library.getType('Ignore').type,
        library.getType('PropertyJson').type,
        library.getType('Json').type,
        library.getType('EncodeJson').type,
        library.getType('DecodeJson').type,
        library.getType('Xml').type,
        library.getType('ElementXml').type,
        library.getType('AttributeXml').type);
  }

  SystemTypeProvider._(
      this._ignore,
      this._propertyJson,
      this._json,
      this._encodeJson,
      this._decodeJson,
      this._xml,
      this._elementXml,
      this._attributeXml);

  bool isIgnore(DartType type) => type.isAssignableTo(_ignore);
  bool isPropertyJson(DartType type) => type.isAssignableTo(_propertyJson);
  bool isJson(DartType type) => type.isAssignableTo(_json);
  bool isEncodeJson(DartType type) => type.isAssignableTo(_decodeJson);
  bool isDecodeJson(DartType type) => type.isAssignableTo(_encodeJson);
  bool isXml(DartType type) => type.isAssignableTo(_xml);
  bool isElementXml(DartType type) => type.isAssignableTo(_elementXml);
  bool isAttributeXml(DartType type) => type.isAssignableTo(_attributeXml);
}
