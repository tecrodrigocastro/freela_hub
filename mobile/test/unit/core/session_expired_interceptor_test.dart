import 'package:base_clean_arch_bloc/src/core/cache/shared_preferences/shared_preferences_impl.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/session_expired_interceptor.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

RestClientResponse _response(int status, {Map<String, dynamic>? headers}) =>
    RestClientResponse(
      request: RestClientRequest(path: '/vagas', headers: headers),
      statusCode: status,
    );

void main() {
  late SessionService session;
  late SessionExpiredInterceptor interceptor;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'token': '1|abc'});
    session = SessionService(sharedPreferencesImpl: SharedPreferencesImpl());
    interceptor = SessionExpiredInterceptor(sessionService: session);
  });

  test('401 autenticado remove o token e emite sessão expirada', () async {
    final expired = expectLater(session.onSessionExpired, emits(isNull));

    await interceptor
        .onResponse(_response(401, headers: {'Authorization': 'Bearer 1|abc'}));

    await expired;
    expect(await session.hasSession(), isFalse);
  });

  test('401 sem Authorization (login) não mexe na sessão', () async {
    await interceptor.onResponse(_response(401));

    expect(await session.hasSession(), isTrue);
  });

  test('respostas que não são 401 mantêm a sessão', () async {
    await interceptor
        .onResponse(_response(422, headers: {'Authorization': 'Bearer 1|abc'}));

    expect(await session.hasSession(), isTrue);
  });
}
