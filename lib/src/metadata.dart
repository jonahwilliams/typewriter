import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

///
typedef String Writer(String input);

///
class CompositeTypeMetadata implements TypeMetadata {
  ///
  final ClassElement element;
  final List<FieldElement> fields;
  final DartType _type;

  ///
  const CompositeTypeMetadata(this._type, this.element, this.fields);

  @override
  String get displayName => _type.displayName;
}


/// A way of tracking additional information about types and codecs to be generated.
class MetadataRegistry {
  final Map<DartType, TypeMetadata> _metadata;

  /// Builds a [MetadataRegistry] from a resolve dart:core library element.
  factory MetadataRegistry(LibraryElement coreLibrary) {
    final provider = coreLibrary.context.typeProvider;
    final dateTimeType = coreLibrary.getType('DateTime').type;
    final regexType = coreLibrary.getType('RegExp').type;
    final symbolType = coreLibrary.getType('Symbol').type;
    final metadata = <DartType, TypeMetadata>{
      provider.boolType:
          new ScalarTypeMetadata(provider.boolType, _identity, _identity),
      provider.doubleType:
          new ScalarTypeMetadata(provider.doubleType, _identity, _identity),
      provider.intType:
          new ScalarTypeMetadata(provider.intType, _identity, _identity),
      provider.stringType:
          new ScalarTypeMetadata(provider.stringType, _identity, _identity),
      provider.nullType:
          new ScalarTypeMetadata(provider.nullType, _identity, (x) => 'null'),
      dateTimeType: new ScalarTypeMetadata(dateTimeType,
          (x) => '$x.toIso8601String()', (x) => 'DateTime.parse($x)'),
      regexType: new ScalarTypeMetadata(
          regexType, (x) => '$x.pattern', (x) => 'new RegExp($x)'),
      symbolType: new ScalarTypeMetadata(
          symbolType, (x) => '$x.toString()', (x) => 'new Symbol($x)')
    };
    return new MetadataRegistry._(metadata);
  }

  MetadataRegistry._(this._metadata);

  /// Returns all of the [CompositeTypeMetadata] in the registry.
  Iterable<CompositeTypeMetadata> get compositeTypes =>
      _metadata.values.where((data) => data is CompositeTypeMetadata);
  
  /// Returns all of the [ScalarTypeMetadata] in the registry.
  Iterable<ScalarTypeMetadata> get scalarTypes =>
      _metadata.values.where((data) => data is ScalarTypeMetadata);
  
  /// Adds a [type] with [metadata] to the registry.
  void addType(DartType type, TypeMetadata metadata) {
    _metadata[type] = metadata;
  }

  /// retrieves the [TypeMetadata] associated with [type], or null.
  TypeMetadata getType(DartType type) => _metadata[type];

  static String _identity(String input) => input;
}

///
class ScalarTypeMetadata implements TypeMetadata {
  ///
  final Writer encodeString;

  ///
  final Writer decodeString;
  final DartType _type;

  ///
  const ScalarTypeMetadata(this._type, this.encodeString, this.decodeString);

  ///
  @override
  String get displayName => _type.displayName;
}

///
abstract class TypeMetadata {
  ///
  String get displayName;
}
