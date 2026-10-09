import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/get_candidaturas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidaturas_page_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/get_candidaturas_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/retirar_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidaturas_bloc.dart';
import 'package:base_clean_arch_bloc/routes.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/login_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/register_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/dtos/update_perfil_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/entities/perfil_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/repositories/perfil_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/get_perfil_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/logout_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/update_perfil_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/presentation/bloc/perfil_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vagas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vagas_page_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_categorias_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vagas_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vagas_bloc.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:result_dart/result_dart.dart';
import 'package:base_clean_arch_bloc/src/core/cache/shared_preferences/shared_preferences_impl.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockCheckSessionUsecase extends Mock implements CheckSessionUsecase {}

class MockGetVagasUsecase extends Mock implements GetVagasUsecase {}

class MockGetCategoriasUsecase extends Mock implements GetCategoriasUsecase {}

class MockGetCandidaturasUsecase extends Mock implements GetCandidaturasUsecase {}

class MockRetirarCandidaturaUsecase extends Mock implements RetirarCandidaturaUsecase {}

class MockGetPerfilUsecase extends Mock implements GetPerfilUsecase {}

class MockUpdatePerfilUsecase extends Mock implements UpdatePerfilUsecase {}

class MockPerfilRepository extends Mock implements IPerfilRepository {}

void main() {
  late SessionService session;
  late GoRouter router;
  late MockPerfilRepository perfilRepository;

  setUpAll(() {
    registerFallbackValue(GetCandidaturasParams.empty());
    registerFallbackValue(GetVagasParams.empty());
    registerFallbackValue(NoParams());
    registerFallbackValue(UpdatePerfilParams.empty());
  });

  setUp(() {
    final getVagas = MockGetVagasUsecase();
    final getCategorias = MockGetCategoriasUsecase();
    when(() => getVagas.call(any())).thenAnswer((_) async => const Success(VagasPageEntity(vagas: [], currentPage: 1, lastPage: 1)));
    when(() => getCategorias.call(any())).thenAnswer((_) async => const Success([]));
    injector.registerFactory(() => VagasBloc(getVagasUsecase: getVagas, getCategoriasUsecase: getCategorias));
    session = SessionService(sharedPreferencesImpl: SharedPreferencesImpl());
    injector.registerSingleton<SessionService>(session);

    final getPerfil = MockGetPerfilUsecase();
    when(() => getPerfil.call(any())).thenAnswer((_) async => const Success(PerfilEntity(id: 4, name: 'Ana Souza', email: 'ana@email.com')));
    perfilRepository = MockPerfilRepository();
    when(() => perfilRepository.logout()).thenAnswer((_) async => const Success(unit));
    // O LogoutUsecase é o real: o teste confere que o "Sair" limpa a sessão de verdade.
    final getCandidaturas = MockGetCandidaturasUsecase();
    when(() => getCandidaturas.call(any())).thenAnswer((_) async => const Success(CandidaturasPageEntity(candidaturas: [], currentPage: 1, lastPage: 1)));
    injector.registerFactory(() => CandidaturasBloc(getCandidaturasUsecase: getCandidaturas, retirarCandidaturaUsecase: MockRetirarCandidaturaUsecase()));
    injector.registerFactory(() => PerfilBloc(
          getPerfilUsecase: getPerfil,
          updatePerfilUsecase: MockUpdatePerfilUsecase(),
          logoutUsecase: LogoutUsecase(perfilRepository: perfilRepository, sessionService: session),
        ));
    injector.registerFactory(() => AuthBloc(
          loginUsecase: MockLoginUsecase(),
          registerUsecase: MockRegisterUsecase(),
          checkSessionUsecase: MockCheckSessionUsecase(),
        ));
  });

  tearDown(() async {
    router.dispose();
    await injector.reset();
  });

  Future<void> pump(WidgetTester tester, {required bool loggedIn, required String at}) async {
    SharedPreferences.setMockInitialValues(loggedIn ? {'token': '1|abc'} : {});
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    router = createRouter(sessionService: session, initialLocation: at);
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
    await tester.pumpAndSettle();
  }

  String location() => router.routeInformationProvider.value.uri.path;

  group('guard de sessão', () {
    testWidgets('sem sessão, rota protegida cai no login', (tester) async {
      await pump(tester, loggedIn: false, at: AppPaths.vagas);

      expect(location(), AppPaths.login);
      expect(find.text('Acesse as vagas e acompanhe suas candidaturas.'), findsOneWidget);
    });

    testWidgets('sem sessão, o cadastro continua acessível', (tester) async {
      await pump(tester, loggedIn: false, at: AppPaths.cadastro);

      expect(location(), AppPaths.cadastro);
    });

    testWidgets('com sessão, login e cadastro redirecionam para as vagas', (tester) async {
      await pump(tester, loggedIn: true, at: AppPaths.login);

      expect(location(), AppPaths.vagas);
      expect(find.text('Candidaturas'), findsOneWidget); // aba na bottom nav
    });

    testWidgets('401 da API (sessão expirada) devolve ao login', (tester) async {
      await pump(tester, loggedIn: true, at: AppPaths.vagas);
      expect(location(), AppPaths.vagas);

      await session.expireSession();
      await tester.pumpAndSettle();

      expect(location(), AppPaths.login);
    });

    testWidgets('Sair no Perfil limpa a sessão e volta ao login', (tester) async {
      await pump(tester, loggedIn: true, at: AppPaths.perfil);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Sair'));
      await tester.pumpAndSettle();

      verify(() => perfilRepository.logout()).called(1); // revoga o token no servidor
      expect(location(), AppPaths.login);
      expect(await session.hasSession(), isFalse);
    });
  });

  group('bottom navigation', () {
    testWidgets('mostra as três abas e navega entre elas', (tester) async {
      await pump(tester, loggedIn: true, at: AppPaths.vagas);

      for (final label in ['Vagas', 'Candidaturas', 'Perfil']) {
        expect(find.text(label), findsWidgets);
      }

      await tester.tap(find.text('Candidaturas').last);
      await tester.pumpAndSettle();
      expect(location(), AppPaths.candidaturas);

      await tester.tap(find.text('Perfil').last);
      await tester.pumpAndSettle();
      expect(location(), AppPaths.perfil);

      await tester.tap(find.text('Vagas').last);
      await tester.pumpAndSettle();
      expect(location(), AppPaths.vagas);
    });

    testWidgets('aba selecionada é exposta para acessibilidade', (tester) async {
      await pump(tester, loggedIn: true, at: AppPaths.candidaturas);

      final selected = tester.getSemantics(find.bySemanticsLabel('Candidaturas').last);
      expect(selected.flagsCollection.isSelected, isTrue);
    });
  });
}
