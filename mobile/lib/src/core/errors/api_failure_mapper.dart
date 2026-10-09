import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/errors/unauthorized_exception.dart';

/// Converte uma resposta 4xx da API (o cliente HTTP não lança para 4xx) em exceção:
/// 422 → [ValidationException] com os erros por campo, 401 → [UnauthorizedException],
/// 404 com [notFoundMessage] → [NotFoundException] (a mensagem da API é técnica),
/// demais → [DefaultException] com o status.
BaseException mapApiFailure(int status, dynamic data, {String? notFoundMessage}) {
  final body = data is Map ? data : const {};
  final message = body['message'] as String? ?? 'Não foi possível concluir a solicitação.';

  if (status == 422) {
    final raw = body['errors'];
    final fieldErrors = <String, List<String>>{
      if (raw is Map) for (final entry in raw.entries) entry.key.toString(): [for (final m in entry.value as List) m.toString()],
    };
    final first = fieldErrors.values.where((v) => v.isNotEmpty).map((v) => v.first).firstOrNull;
    return ValidationException(message: first ?? message, fieldErrors: fieldErrors);
  }
  if (status == 404 && notFoundMessage != null) {
    return NotFoundException(message: notFoundMessage);
  }
  if (status == 401) {
    return UnauthorizedException(message: message);
  }
  return DefaultException(message: message, statusCode: status);
}
