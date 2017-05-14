import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

/// Provides [DartType]s for the annotation elements.
class SystemTypeProvider {
  final DartType _ignore,
      _deriveJson,
      _deriveXml,
      _jsonProperty,
      _xmlElement,
      _xmlAttribute;

  /// Builds a new [SystemTypeProvider] from the package:typewriter
  /// annotation library element.
  factory SystemTypeProvider(LibraryElement library) {
    return new SystemTypeProvider._(
      library.getType('ignore').type,
      library.getType('deriveJson').type,
      library.getType('deriveXml').type,
      library.getType('xmlElement').type,
      library.getType('xmlAttribute').type,
      library.getType('jsonProperty').type,
    );
  }

  SystemTypeProvider._(
    this._ignore,
    this._deriveJson,
    this._deriveXml,
    this._xmlElement,
    this._xmlAttribute,
    this._jsonProperty,
  );

  bool isIgnore(DartType type) => type.isAssignableTo(_ignore);
  bool isJsonProperty(DartType type) => type.isAssignableTo(_jsonProperty);
  bool isDeriveJson(DartType type) => type.isAssignableTo(_deriveJson);
  bool isDeriveXml(DartType type) => type.isAssignableTo(_deriveXml);
  bool isXmlElement(DartType type) => type.isAssignableTo(_xmlElement);
  bool isXmlAttribute(DartType type) => type.isAssignableTo(_xmlAttribute);
}
