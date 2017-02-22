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

  /// An annotation which switchs to a custom encoder/decoder strategy.
  final DartType jsonEncoder;

  /// Same as above, must be paired to work correctly.
  final DartType jsonDecoder;

  /// Builds a new [SystemTypeProvider] from the package:typewriter annotation library element.
  factory SystemTypeProvider(LibraryElement library) {
    return new SystemTypeProvider._(
        library.getType('Ignore').type,
        library.getType('JsonKey').type,
        library.getType('Json').type,
        library.getType('JsonEncoder').type,
        library.getType('JsonDecoder').type);
  }

  SystemTypeProvider._(
      this.ignore, this.jsonKey, this.json, this.jsonEncoder, this.jsonDecoder);
}
