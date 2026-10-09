import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/dtos/update_perfil_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/entities/perfil_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/get_perfil_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/logout_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/update_perfil_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/presentation/bloc/perfil_bloc.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import 'support.dart';

class MockGetPerfilUsecase extends Mock implements GetPerfilUsecase {}

class MockUpdatePerfilUsecase extends Mock implements UpdatePerfilUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

void main() {
  late MockGetPerfilUsecase getPerfil;
  late MockUpdatePerfilUsecase updatePerfil;
  late MockLogoutUsecase logout;

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(UpdatePerfilParams.empty());
  });

  setUp(() {
    getPerfil = MockGetPerfilUsecase();
    updatePerfil = MockUpdatePerfilUsecase();
    logout = MockLogoutUsecase();
  });

  PerfilBloc build() => PerfilBloc(getPerfilUsecase: getPerfil, updatePerfilUsecase: updatePerfil, logoutUsecase: logout);

  group('carregar', () {
    blocTest<PerfilBloc, PerfilState>(
      'emite loading e depois o perfil',
      build: build,
      setUp: () => when(() => getPerfil.call(any())).thenAnswer((_) async => const Success(perfilAna)),
      act: (bloc) => bloc.add(const PerfilStarted()),
      expect: () => [const PerfilLoading(), const PerfilLoaded(perfilAna)],
    );

    blocTest<PerfilBloc, PerfilState>(
      'falha de rede emite PerfilFailure e permite tentar de novo',
      build: build,
      setUp: () {
        var calls = 0;
        when(() => getPerfil.call(any())).thenAnswer((_) async => ++calls == 1 ? const Failure(NetworkException()) : const Success(perfilAna));
      },
      act: (bloc) async {
        bloc.add(const PerfilStarted());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const PerfilStarted());
      },
      expect: () => [
        const PerfilLoading(),
        isA<PerfilFailure>().having((s) => s.exception, 'exception', isA<NetworkException>()),
        const PerfilLoading(),
        const PerfilLoaded(perfilAna),
      ],
    );
  });

  group('salvar bio', () {
    const atualizado = PerfilEntity(id: 4, name: 'Ana Souza', email: 'ana@email.com', bio: 'Nova bio');

    blocTest<PerfilBloc, PerfilState>(
      'envia a bio e emite o perfil atualizado',
      build: build,
      seed: () => const PerfilLoaded(perfilAna),
      setUp: () => when(() => updatePerfil.call(any())).thenAnswer((_) async => const Success(atualizado)),
      act: (bloc) => bloc.add(const PerfilBioSaved('Nova bio')),
      expect: () => [const PerfilSaving(perfilAna), const PerfilSaved(atualizado)],
      verify: (_) => expect(verify(() => updatePerfil.call(captureAny())).captured.single, UpdatePerfilParams(bio: 'Nova bio')),
    );

    blocTest<PerfilBloc, PerfilState>(
      '422 da API fica no campo bio e mantém o perfil na tela',
      build: build,
      seed: () => const PerfilLoaded(perfilAna),
      setUp: () => when(() => updatePerfil.call(any())).thenAnswer((_) async => const Failure(ValidationException(
            message: 'bio inválida',
            fieldErrors: {
              'bio': ['bio inválida'],
            },
          ))),
      act: (bloc) => bloc.add(const PerfilBioSaved('x')),
      expect: () => [
        const PerfilSaving(perfilAna),
        isA<PerfilSaveFailure>().having((s) => s.perfil, 'perfil', perfilAna).having((s) => s.bioError, 'bioError', 'bio inválida'),
      ],
    );

    blocTest<PerfilBloc, PerfilState>(
      'bio acima de 1000 caracteres é barrada antes de chamar a API',
      build: build,
      seed: () => const PerfilLoaded(perfilAna),
      act: (bloc) => bloc.add(PerfilBioSaved('a' * 1001)),
      expect: () => [
        const PerfilSaving(perfilAna),
        isA<PerfilSaveFailure>().having((s) => s.bioError, 'bioError', contains('1000')),
      ],
      verify: (_) => verifyNever(() => updatePerfil.call(any())),
    );

    blocTest<PerfilBloc, PerfilState>(
      'erro de rede não é erro de campo',
      build: build,
      seed: () => const PerfilLoaded(perfilAna),
      setUp: () => when(() => updatePerfil.call(any())).thenAnswer((_) async => const Failure(NetworkException())),
      act: (bloc) => bloc.add(const PerfilBioSaved('Nova')),
      expect: () => [
        const PerfilSaving(perfilAna),
        isA<PerfilSaveFailure>().having((s) => s.bioError, 'bioError', isNull).having((s) => s.exception, 'exception', isA<NetworkException>()),
      ],
    );

    blocTest<PerfilBloc, PerfilState>(
      'sem perfil carregado não faz nada',
      build: build,
      act: (bloc) => bloc.add(const PerfilBioSaved('Nova')),
      expect: () => <PerfilState>[],
      verify: (_) => verifyNever(() => updatePerfil.call(any())),
    );
  });

  group('sair', () {
    blocTest<PerfilBloc, PerfilState>(
      'encerra a sessão e emite PerfilLoggedOut',
      build: build,
      seed: () => const PerfilLoaded(perfilAna),
      setUp: () => when(() => logout.call(any())).thenAnswer((_) async => const Success(unit)),
      act: (bloc) => bloc.add(const PerfilLogoutRequested()),
      expect: () => [const PerfilLoggingOut(perfilAna), const PerfilLoggedOut()],
      verify: (_) => verify(() => logout.call(any())).called(1),
    );

    blocTest<PerfilBloc, PerfilState>(
      'toques repetidos em "Sair" chamam o logout uma vez',
      build: build,
      seed: () => const PerfilLoaded(perfilAna),
      setUp: () => when(() => logout.call(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return const Success(unit);
      }),
      act: (bloc) => bloc
        ..add(const PerfilLogoutRequested())
        ..add(const PerfilLogoutRequested()),
      wait: const Duration(milliseconds: 80),
      verify: (_) => verify(() => logout.call(any())).called(1),
    );
  });
}
