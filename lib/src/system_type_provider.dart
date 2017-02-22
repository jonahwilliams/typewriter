import 'dart:core';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:resolver/src/analyzer.dart';

abstract class SystemTypeProvider {
  DartType get ignore;

  DartType get json;

  DartType get jsonDecoder;

  DartType get jsonEncoder;

  DartType get jsonKey;
}

class SystemTypeProviderImpl implements SystemTypeProvider {
  @override
  final DartType ignore;
  @override
  final DartType jsonKey;
  @override
  final DartType json;
  @override
  final DartType jsonEncoder;
  @override
  final DartType jsonDecoder;

  factory SystemTypeProviderImpl(LibraryElement library) {
    return new SystemTypeProviderImpl._(
        library.getType('Ignore').type,
        library.getType('JsonKey').type,
        library.getType('Json').type,
        library.getType('JsonEncoder').type,
        library.getType('JsonDecoder').type);
  }

  SystemTypeProviderImpl._(
      this.ignore, this.jsonKey, this.json, this.jsonEncoder, this.jsonDecoder);
}
