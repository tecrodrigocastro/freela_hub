import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/register_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/entities/auth_response_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/entities/user_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/register_usecase.dart';
import 'package:base_clean_arch_bloc/src/core/cache/shared_preferences/shared_preferences_impl.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SessionService session;
  final params = RegisterParams(name: 'Ana', email: 'a@a.com', password: 'secret123', passwordConfirmation: 'secret123');

  setUpAll(() => registerFallbackValue(params));

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = MockAuthRepository();
    session = SessionService(sharedPreferencesImpl: SharedPreferencesImpl());
  });

  test('RegisterUsecase salva o token ao cadastrar', () async {
    when(() => repository.register(any())).thenAnswer(
      (_) async => const Success(AuthResponseEntity(user: UserEntity(id: '4', email: 'a@a.com', name: 'Ana'), token: '1|abc')),
    );

    await RegisterUsecase(authRepository: repository, sessionService: session).call(params);

    expect(await session.getToken(), '1|abc');
  });

  test('RegisterUsecase não salva token quando falha', () async {
    when(() => repository.register(any())).thenAnswer((_) async => const Failure(DefaultException(message: 'erro')));

    final result = await RegisterUsecase(authRepository: repository, sessionService: session).call(params);

    expect(result.isError(), isTrue);
    expect(await session.hasSession(), isFalse);
  });

  test('CheckSessionUsecase reflete a existência do token', () async {
    final usecase = CheckSessionUsecase(sessionService: session);
    expect(await usecase.call(NoParams()).getOrNull(), isFalse);

    await session.saveSession('1|abc');
    expect(await usecase.call(NoParams()).getOrNull(), isTrue);
  });
}
