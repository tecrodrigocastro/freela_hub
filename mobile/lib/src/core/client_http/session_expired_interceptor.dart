import 'dart:async';

import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';

/// Encerra a sessão local quando a API responde 401 a uma chamada autenticada.
/// Ignora 401 sem `Authorization` (ex.: login), que não indica sessão expirada.
class SessionExpiredInterceptor implements IClientInterceptor {
  final SessionService _sessionService;

  SessionExpiredInterceptor({required SessionService sessionService})
      : _sessionService = sessionService;

  @override
  FutureOr<RestClientHttpMessage> onRequest(RestClientRequest request) =>
      request;

  @override
  FutureOr<RestClientHttpMessage> onResponse(
      RestClientResponse response) async {
    final hadToken =
        response.request.headers?.containsKey('Authorization') ?? false;

    if (response.statusCode == 401 && hadToken) {
      await _sessionService.expireSession();
    }

    return response;
  }

  @override
  FutureOr<RestClientHttpMessage> onError(RestClientException error) => error;
}
