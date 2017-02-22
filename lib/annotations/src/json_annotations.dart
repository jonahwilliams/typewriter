part of typewriter.annotations;

/// Allows renaming of the JSON key associated with a field.
class JsonKey implements DataAnnotation {
  @override
  final String key;

  @override
  final int position = -1;

  ///
  const JsonKey(this.key);
}

///
class Json implements ClassAnnotation {
  ///
  const Json();
}

///
class JsonEncoder implements EncodeAnnotation {
  ///
  const JsonEncoder();
}

///
class JsonDecoder implements DecodeAnnotation {
  ///
  const JsonDecoder();
}
