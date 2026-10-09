import 'dart:async';

import 'package:base_clean_arch_bloc/src/core/cache/cache.dart';
import 'package:base_clean_arch_bloc/src/core/cache/shared_preferences/shared_preferences_impl.dart';

class SessionService {
  final SharedPreferencesImpl _sharedPreferencesImpl;
  final StreamController<void> _expiredController =
      StreamController<void>.broadcast();

  SessionService({
    required SharedPreferencesImpl sharedPreferencesImpl,
  }) : _sharedPreferencesImpl = sharedPreferencesImpl;

  /// Emite quando a API rejeita o token (401). A camada de apresentação escuta
  /// para voltar ao login.
  Stream<void> get onSessionExpired => _expiredController.stream;

  Future<bool> saveSession(String value) async {
    final response = await _sharedPreferencesImpl.setData(
      params: CacheParams(key: 'token', value: value),
    );

    return response;
  }

  Future<String?> getToken() async {
    final response = await _sharedPreferencesImpl.getData('token');

    if (response == null || response.isEmpty) {
      return null;
    }

    return response as String;
  }

  Future<bool> hasSession() async => await getToken() != null;

  Future<bool> removeToken() async {
    final response = await _sharedPreferencesImpl.removeData('token');

    return response;
  }

  /// Descarta o token inválido e avisa quem estiver escutando.
  Future<void> expireSession() async {
    await removeToken();
    _expiredController.add(null);
  }
}
