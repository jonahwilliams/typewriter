part of typewriter.annotations;

/// Allows renaming of the JSON key associated with a field.
class JsonKey implements DataAnnotation {
  @override
  final String key;

  /// Creates a [JsonKey] annotation.
  const JsonKey(this.key);
}

///
class Json implements ClassAnnotation {
  /// TODO: think of better name
  final bool useCustomCodec;

  ///
  const Json({this.useCustomCodec = false});
}

///
class JsonEncode implements EncodeAnnotation {
  ///
  const JsonEncode();
}

///
class JsonDecode implements DecodeAnnotation {
  ///
  const JsonDecode();
}
