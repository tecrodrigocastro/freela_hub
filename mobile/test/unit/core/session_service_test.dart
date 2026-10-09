import 'package:base_clean_arch_bloc/src/core/cache/shared_preferences/shared_preferences_impl.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SessionService session;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    session = SessionService(sharedPreferencesImpl: SharedPreferencesImpl());
  });

  test('hasSession reflete o token salvo', () async {
    expect(await session.hasSession(), isFalse);

    await session.saveSession('2|def');
    expect(await session.hasSession(), isTrue);
    expect(await session.getToken(), '2|def');

    await session.removeToken();
    expect(await session.hasSession(), isFalse);
  });
}
