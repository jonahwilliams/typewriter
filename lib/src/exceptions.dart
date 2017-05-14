/// Occurs when a Class uses the `extends` keyword to implement
/// inheritance, which is disallowed for typewriter classes.
///
/// Though extends is allowed as long as the class is Object.
class ClassUsingExtendsKeywordException implements Exception {
  final String _className;

  /// Creates a new exception for a class named [_className].
  const ClassUsingExtendsKeywordException(this._className);

  @override
  String toString() =>
      'Cannot generate a codec for $_className, because it extends a class'
      'other than object.';
}

/// Occurs when a Class has a default constructor with arguments.
///
///
class ClassNoArgConstructorException implements Exception {
  final String _className;

  const ClassNoArgConstructorException(this._className);

  @override
  String toString() =>
      'Cannot generate a codec for $_className, because the default constructor'
      ' has arguments.';
}

/// Occurs when a class has a final field.
class ClassFinalFieldException implements Exception {
  final String _className;

  const ClassFinalFieldException(this._className);

  @override
  String toString() =>
      'Cannot generate a codec for $_className, because it has final fields';
}
