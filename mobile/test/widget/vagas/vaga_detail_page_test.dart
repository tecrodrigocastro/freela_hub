import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vaga_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vagas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_categorias_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vaga_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vagas_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vaga_detail_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vagas_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/pages/vaga_detail_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/pages/vagas_page.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../unit/vagas/support.dart';

class MockGetVagaUsecase extends Mock implements GetVagaUsecase {}

class MockGetVagasUsecase extends Mock implements GetVagasUsecase {}

class MockGetCategoriasUsecase extends Mock implements GetCategoriasUsecase {}

void main() {
  late MockGetVagaUsecase getVaga;
  late MockGetVagasUsecase getVagas;
  late GoRouter router;

  setUpAll(() {
    registerFallbackValue(GetVagaParams.empty());
    registerFallbackValue(GetVagasParams.empty());
    registerFallbackValue(NoParams());
  });

  setUp(() {
    getVaga = MockGetVagaUsecase();
    getVagas = MockGetVagasUsecase();
    final getCategorias = MockGetCategoriasUsecase();
    when(() => getCategorias.call(any())).thenAnswer((_) async => const Success([]));
    when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(12)])));
    injector
      ..registerFactory(() => VagaDetailBloc(getVagaUsecase: getVaga))
      ..registerFactory(() => VagasBloc(getVagasUsecase: getVagas, getCategoriasUsecase: getCategorias));
  });

  tearDown(() async {
    router.dispose();
    await injector.reset();
  });

  // push empilha sem atualizar o routeInformationProvider: a configuração atual é a fonte.
  String location() => router.routerDelegate.currentConfiguration.last.matchedLocation;

  /// Lista em `/vagas`, detalhe empilhado em `/vagas/:id` e um destino para o "Candidatar-se".
  Future<void> pump(WidgetTester tester, {String at = '/vagas/12'}) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    router = GoRouter(
      initialLocation: at,
      routes: [
        GoRoute(
          path: AppPaths.vagas,
          builder: (_, __) => const VagasPage(),
          routes: [
            GoRoute(path: ':id', builder: (_, state) => VagaDetailPage(vagaId: int.parse(state.pathParameters['id']!)), routes: [
              GoRoute(path: 'candidatar', builder: (_, __) => const Scaffold(body: Text('TELA CANDIDATAR'))),
            ]),
          ],
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('mostra título, empresa, chips, valor, prazo, descrição e total', (tester) async {
    when(() => getVaga.call(any())).thenAnswer((_) async => Success(vagaDetail()));

    await pump(tester);

    expect(find.text('Vaga'), findsOneWidget);
    expect(find.text('App Flutter para clínica'), findsOneWidget);
    expect(find.text('Clínica Vida'), findsOneWidget);
    expect(find.text('Desenvolvimento Mobile'), findsOneWidget);
    expect(find.text('Remoto'), findsOneWidget);
    expect(find.text('Valor (fixo)'), findsOneWidget);
    expect(find.text('R\$ 3.000 – R\$ 5.000'), findsOneWidget);
    expect(find.text('Prazo'), findsOneWidget);
    expect(find.text('45 dias'), findsOneWidget);
    expect(find.text('SOBRE A VAGA'), findsOneWidget);
    expect(find.text('Precisamos de um app para agendamento.'), findsOneWidget);
    expect(find.text('Experiência com BLoC é um diferencial.'), findsOneWidget); // parágrafos separados
    expect(find.text('7 candidaturas até agora'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Candidatar-se'), findsOneWidget);
    expect(verify(() => getVaga.call(captureAny())).captured.single, GetVagaParams(id: 12));
  });

  testWidgets('vaga por hora e sem prazo', (tester) async {
    when(() => getVaga.call(any())).thenAnswer(
      (_) async => Success(vagaDetail(tipo: TipoPagamento.hora, min: 90, max: 130, prazo: null, total: 1)),
    );

    await pump(tester);

    expect(find.text('Valor (por hora)'), findsOneWidget);
    expect(find.text('R\$ 90 – R\$ 130'), findsOneWidget);
    expect(find.text('Prazo'), findsNothing);
    expect(find.text('1 candidatura até agora'), findsOneWidget);
  });

  testWidgets('ja_candidatou: botão "Candidatura enviada" desabilitado', (tester) async {
    when(() => getVaga.call(any())).thenAnswer((_) async => Success(vagaDetail(jaCandidatou: true)));

    await pump(tester);

    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Candidatura enviada'));
    expect(button.onPressed, isNull);
    expect(find.text('Candidatar-se'), findsNothing);
  });

  testWidgets('"Candidatar-se" abre a tela de candidatura da vaga', (tester) async {
    when(() => getVaga.call(any())).thenAnswer((_) async => Success(vagaDetail()));
    await pump(tester);

    await tester.tap(find.text('Candidatar-se'));
    await tester.pumpAndSettle();

    expect(find.text('TELA CANDIDATAR'), findsOneWidget);
    expect(location(), '/vagas/12/candidatar');
  });

  testWidgets('skeleton enquanto carrega', (tester) async {
    when(() => getVaga.call(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(seconds: 1));
      return Success(vagaDetail());
    });

    await pump(tester);
    expect(find.text('App Flutter para clínica'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('App Flutter para clínica'), findsOneWidget);
  });

  testWidgets('404: mensagem de vaga indisponível e botão de voltar para as vagas', (tester) async {
    when(() => getVaga.call(any())).thenAnswer((_) async => Failure(NotFoundException(message: 'Esta vaga não está mais disponível.')));

    await pump(tester);

    expect(find.text('Vaga indisponível'), findsOneWidget);
    expect(find.text('Esta vaga não está mais disponível.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsNothing);

    await tester.tap(find.text('Voltar para as vagas'));
    await tester.pumpAndSettle();

    expect(location(), AppPaths.vagas);
    expect(find.text('Buscar por título ou descrição'), findsOneWidget);
  });

  testWidgets('erro de rede: retry recarrega', (tester) async {
    var calls = 0;
    when(() => getVaga.call(any())).thenAnswer((_) async => ++calls == 1 ? const Failure(NetworkException()) : Success(vagaDetail()));
    await pump(tester);

    expect(find.text('Não foi possível carregar'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();
    await tester.pump();

    expect(find.text('App Flutter para clínica'), findsOneWidget);
  });

  testWidgets('tocar num card da lista abre o detalhe e a seta volta para a lista', (tester) async {
    when(() => getVaga.call(any())).thenAnswer((_) async => Success(vagaDetail()));
    await pump(tester, at: AppPaths.vagas);

    await tester.tap(find.text('App Flutter para clínica'));
    await tester.pumpAndSettle();

    expect(location(), '/vagas/12');
    expect(find.text('SOBRE A VAGA'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(location(), AppPaths.vagas);
    expect(find.text('Buscar por título ou descrição'), findsOneWidget);
  });

  testWidgets('abrindo o detalhe direto (sem pilha) a seta leva às vagas', (tester) async {
    when(() => getVaga.call(any())).thenAnswer((_) async => Success(vagaDetail()));
    await pump(tester);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(location(), AppPaths.vagas);
  });
}
