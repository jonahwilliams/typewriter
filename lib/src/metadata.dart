import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:resolver/src/analyzer.dart';

typedef String Writer(String input);

class CompositeTypeMetadata implements TypeMetadata {
  final ClassElement element;
  final DartType _type;
  const CompositeTypeMetadata(this._type, this.element);

  String get displayName => _type.displayName;
}

abstract class MetadataRegistry {
  Iterable<CompositeTypeMetadata> get compositeTypes;

  Iterable<ScalarTypeMetadata> get scalarTypes;

  void addType(DartType type, TypeMetadata metadata);

  TypeMetadata getType(DartType type);
}

class MetadataRegistryImpl implements MetadataRegistry {
  final Map<DartType, TypeMetadata> _metadata;
  factory MetadataRegistryImpl(
      AnalysisContext context, LibraryElement coreLibrary) {
    final provider = context.typeProvider;
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
          (x) => '${x}.toIso8601String()', (x) => 'DateTime.parse(${x})'),
      regexType: new ScalarTypeMetadata(
          regexType, (x) => '${x}.pattern', (x) => 'new RegExp(${x})'),
      symbolType: new ScalarTypeMetadata(
          symbolType, (x) => '${x}.toString()', (x) => 'new Symbol(${x})')
    };
    return new MetadataRegistryImpl._(metadata);
  }

  MetadataRegistryImpl._(this._metadata);

  @override
  Iterable<CompositeTypeMetadata> get compositeTypes =>
      _metadata.values.where((data) => data is CompositeTypeMetadata);

  @override
  Iterable<ScalarTypeMetadata> get scalarTypes =>
      _metadata.values.where((data) => data is ScalarTypeMetadata);

  @override
  void addType(DartType type, TypeMetadata metadata) {
    _metadata[type] = metadata;
  }

  @override
  TypeMetadata getType(DartType type) => _metadata[type];

  static String _identity(String input) => input;
}

class ScalarTypeMetadata implements TypeMetadata {
  final Writer encodeString;
  final Writer decodeString;
  final DartType _type;

  const ScalarTypeMetadata(this._type, this.encodeString, this.decodeString);

  String get displayName => _type.displayName;
}

abstract class TypeMetadata {
  String get displayName;
}
