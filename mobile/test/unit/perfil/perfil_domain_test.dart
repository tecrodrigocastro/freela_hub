import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/dtos/update_perfil_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/repositories/perfil_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/logout_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/validators/update_perfil_params_validators.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/presentation/utils/perfil_formatters.dart';
import 'package:base_clean_arch_bloc/src/core/cache/shared_preferences/shared_preferences_impl.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPerfilRepository extends Mock implements IPerfilRepository {}

void main() {
  group('UpdatePerfilParams', () {
    test('toJson envia só a bio, sem espaços nas pontas', () {
      expect(UpdatePerfilParams(bio: '  Dev Flutter \n').toJson(), {'bio': 'Dev Flutter'});
    });

    test('bio vazia é enviada (limpa a bio)', () {
      expect(UpdatePerfilParams.empty().toJson(), {'bio': ''});
    });

    test('igualdade por valor e setter', () {
      final params = UpdatePerfilParams.empty()..setBio('oi');

      expect(params, UpdatePerfilParams(bio: 'oi'));
      expect(params.hashCode, UpdatePerfilParams(bio: 'oi').hashCode);
    });
  });

  group('UpdatePerfilParamsValidators', () {
    final validator = UpdatePerfilParamsValidators();

    test('aceita bio vazia, normal e com exatamente 1000 caracteres', () {
      expect(validator.validate(UpdatePerfilParams(bio: '')).isValid, isTrue);
      expect(validator.validate(UpdatePerfilParams(bio: 'Dev Flutter')).isValid, isTrue);
      expect(validator.validate(UpdatePerfilParams(bio: 'a' * 1000)).isValid, isTrue);
    });

    test('recusa bio com mais de 1000 caracteres (limite da API)', () {
      final result = validator.validate(UpdatePerfilParams(bio: 'a' * 1001));

      expect(result.isValid, isFalse);
      expect(result.exceptions.first.key, 'bio');
      expect(result.exceptions.first.message, contains('1000'));
    });
  });

  group('iniciaisDe', () {
    test('primeira letra do primeiro e do último nome', () {
      expect(iniciaisDe('Ana Souza'), 'AS');
      expect(iniciaisDe('maria da silva santos'), 'MS');
    });

    test('nome único, espaços extras e vazio', () {
      expect(iniciaisDe('Ana'), 'A');
      expect(iniciaisDe('  ana   souza  '), 'AS');
      expect(iniciaisDe('   '), '?');
    });
  });

  group('LogoutUsecase', () {
    late MockPerfilRepository repository;
    late SessionService session;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = MockPerfilRepository();
      session = SessionService(sharedPreferencesImpl: SharedPreferencesImpl());
      await session.saveSession('4|token');
    });

    test('revoga no servidor e limpa o token local', () async {
      when(() => repository.logout()).thenAnswer((_) async => const Success(unit));

      final result = await LogoutUsecase(perfilRepository: repository, sessionService: session).call(NoParams());

      expect(result.isSuccess(), isTrue);
      verify(() => repository.logout()).called(1);
      expect(await session.hasSession(), isFalse);
    });

    test('mesmo com a API falhando (sem rede) o usuário sai', () async {
      when(() => repository.logout()).thenAnswer((_) async => const Failure(NetworkException()));

      final result = await LogoutUsecase(perfilRepository: repository, sessionService: session).call(NoParams());

      expect(result.isSuccess(), isTrue);
      expect(await session.hasSession(), isFalse);
    });
  });
}
