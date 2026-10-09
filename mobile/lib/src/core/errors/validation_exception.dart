import 'base_exception.dart';

/// Resposta 422 da API: [fieldErrors] traz as mensagens por campo
/// (`{"email": ["..."]}`), [message] a primeira delas.
class ValidationException extends BaseException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors = const {},
    super.statusCode = 422,
  });

  String? firstErrorFor(String field) {
    final errors = fieldErrors[field];
    return errors == null || errors.isEmpty ? null : errors.first;
  }
}
