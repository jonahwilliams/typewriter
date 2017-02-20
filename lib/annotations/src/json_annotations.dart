part of typewriter.annotations;

/// Allows renaming of the JSON key associated with a field.
class JsonKey implements DataAnnotation {
  @override
  final String key;

  @override
  int get position => -1;

  const JsonKey(this.key);
}
