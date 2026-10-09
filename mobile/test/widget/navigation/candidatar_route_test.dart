import 'package:base_clean_arch_bloc/routes.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/enviar_candidatura_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/enviar_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidatura_form_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vaga_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vagas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_categorias_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vaga_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vagas_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vaga_detail_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vagas_bloc.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/cache/shared_preferences/shared_preferences_impl.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../unit/vagas/support.dart';

class MockGetVagaUsecase extends Mock implements GetVagaUsecase {}

class MockGetVagasUsecase extends Mock implements GetVagasUsecase {}

class MockGetCategoriasUsecase extends Mock implements GetCategoriasUsecase {}

class MockEnviarUsecase extends Mock implements EnviarCandidaturaUsecase {}

void main() {
  late GoRouter router;

  setUpAll(() {
    registerFallbackValue(GetVagaParams.empty());
    registerFallbackValue(GetVagasParams.empty());
    registerFallbackValue(EnviarCandidaturaParams.empty());
    registerFallbackValue(NoParams());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'token': '1|abc'});
    final getVaga = MockGetVagaUsecase();
    final getVagas = MockGetVagasUsecase();
    final getCategorias = MockGetCategoriasUsecase();
    when(() => getVaga.call(any())).thenAnswer((_) async => Success(vagaDetail()));
    when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(12)])));
    when(() => getCategorias.call(any())).thenAnswer((_) async => const Success([]));

    injector
      ..registerSingleton<SessionService>(SessionService(sharedPreferencesImpl: SharedPreferencesImpl()))
      ..registerFactory(() => VagaDetailBloc(getVagaUsecase: getVaga))
      ..registerFactory(() => VagasBloc(getVagasUsecase: getVagas, getCategoriasUsecase: getCategorias))
      ..registerFactory(() => CandidaturaFormBloc(enviarCandidaturaUsecase: MockEnviarUsecase()));
  });

  tearDown(() async {
    router.dispose();
    await injector.reset();
  });

  Future<void> pump(WidgetTester tester, String at) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    router = createRouter(sessionService: injector<SessionService>(), initialLocation: at);
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('"Candidatar-se" no detalhe abre o formulário com o resumo da vaga', (tester) async {
    await pump(tester, AppPaths.vagaDetalhe(12));

    await tester.tap(find.text('Candidatar-se'));
    await tester.pumpAndSettle();

    expect(find.text('Enviar candidatura'), findsOneWidget);
    expect(find.text('Clínica Vida · R\$ 3.000 – R\$ 5.000 · 45 dias'), findsOneWidget);
  });

  testWidgets('link direto para o formulário (sem os dados da vaga) cai no detalhe', (tester) async {
    await pump(tester, AppPaths.candidatar(12));

    expect(find.text('SOBRE A VAGA'), findsOneWidget);
    expect(find.text('Enviar candidatura'), findsNothing);
  });
}
