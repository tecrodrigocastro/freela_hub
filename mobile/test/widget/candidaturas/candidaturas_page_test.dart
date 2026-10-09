import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/candidatura_id_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/get_candidaturas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_status.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidaturas_page_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/get_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/get_candidaturas_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/retirar_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidatura_detail_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidaturas_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/pages/candidaturas_page.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/services/candidatura_sent_notifier.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

class MockGetCandidaturas extends Mock implements GetCandidaturasUsecase {}

class MockGetCandidatura extends Mock implements GetCandidaturaUsecase {}

class MockRetirar extends Mock implements RetirarCandidaturaUsecase {}

CandidaturaEntity _c(
  int id, {
  CandidaturaStatus status = CandidaturaStatus.enviada,
  double? valor = 4200,
  String? mensagem,
}) =>
    CandidaturaEntity(
      id: id,
      vagaId: id + 100,
      vagaTitulo: 'Vaga $id',
      vagaEmpresa: 'Clínica Vida',
      valorProposto: valor,
      status: status,
      mensagem: mensagem,
      createdAt: DateTime(2026, 10, 3, 12),
    );

CandidaturasPageEntity _page(List<CandidaturaEntity> items, {int current = 1, int last = 1}) =>
    CandidaturasPageEntity(candidaturas: items, currentPage: current, lastPage: last);

void main() {
  late MockGetCandidaturas getCandidaturas;
  late MockGetCandidatura getCandidatura;
  late MockRetirar retirar;
  late CandidaturaSentNotifier notifier;
  late GoRouter router;

  setUpAll(() {
    registerFallbackValue(GetCandidaturasParams.empty());
    registerFallbackValue(CandidaturaIdParams.empty());
  });

  setUp(() {
    getCandidaturas = MockGetCandidaturas();
    getCandidatura = MockGetCandidatura();
    retirar = MockRetirar();
    notifier = CandidaturaSentNotifier();
    injector
      ..registerFactory(() => CandidaturasBloc(getCandidaturasUsecase: getCandidaturas, retirarCandidaturaUsecase: retirar, sentNotifier: notifier))
      ..registerFactory(() => CandidaturaDetailBloc(getCandidaturaUsecase: getCandidatura));
  });

  tearDown(() async {
    router.dispose();
    await injector.reset();
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const CandidaturasPage()),
      GoRoute(path: AppPaths.vagas, builder: (_, __) => const Scaffold(body: Text('TELA VAGAS'))),
    ]);
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
    await tester.pump();
    await tester.pump();
  }

  void stubList(List<CandidaturaEntity> items) => when(() => getCandidaturas.call(any())).thenAnswer((_) async => Success(_page(items)));

  final all = [
    _c(1, status: CandidaturaStatus.emAnalise),
    _c(2, status: CandidaturaStatus.aprovada, valor: 3200),
    _c(3),
    _c(4, status: CandidaturaStatus.recusada, valor: null),
  ];

  testWidgets('lista os cards com status, empresa, valor e data; "Retirar" só na enviada', (tester) async {
    stubList(all);
    await pump(tester);

    expect(find.text('Candidaturas'), findsOneWidget);
    for (final titulo in ['Vaga 1', 'Vaga 2', 'Vaga 3', 'Vaga 4']) {
      expect(find.text(titulo), findsOneWidget);
    }
    expect(find.text('Em análise'), findsOneWidget);
    expect(find.text('Aprovada'), findsOneWidget);
    expect(find.text('Enviada'), findsOneWidget);
    expect(find.text('Recusada'), findsOneWidget);
    expect(find.text('Clínica Vida'), findsNWidgets(4));
    expect(find.text('R\$ 3.200'), findsOneWidget);
    expect(find.text('03 out 2026'), findsNWidgets(3)); // a enviada mostra o link "Retirar" no lugar da data
    expect(find.text('Retirar candidatura'), findsOneWidget);
  });

  testWidgets('skeleton enquanto carrega', (tester) async {
    when(() => getCandidaturas.call(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(seconds: 1));
      return Success(_page(all));
    });
    await pump(tester);

    expect(find.text('Vaga 1'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Vaga 1'), findsOneWidget);
  });

  testWidgets('vazio: mensagem e botão que leva às vagas', (tester) async {
    stubList([]);
    await pump(tester);

    expect(find.text('Você ainda não se candidatou'), findsOneWidget);

    await tester.tap(find.text('Ver vagas'));
    await tester.pumpAndSettle();

    expect(find.text('TELA VAGAS'), findsOneWidget);
  });

  testWidgets('erro com tentar novamente', (tester) async {
    var calls = 0;
    when(() => getCandidaturas.call(any())).thenAnswer((_) async => ++calls == 1 ? const Failure(NetworkException()) : Success(_page(all)));
    await pump(tester);

    expect(find.text('Não foi possível carregar'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Vaga 1'), findsOneWidget);
  });

  testWidgets('pull-to-refresh recarrega', (tester) async {
    stubList(all);
    await pump(tester);
    clearInteractions(getCandidaturas);

    await tester.fling(find.byType(ListView).last, const Offset(0, 400), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    verify(() => getCandidaturas.call(any())).called(1);
  });

  testWidgets('scroll até o fim carrega a próxima página', (tester) async {
    final first = [for (var i = 1; i <= 10; i++) _c(i, status: CandidaturaStatus.aprovada)];
    when(() => getCandidaturas.call(any())).thenAnswer((invocation) async {
      final params = invocation.positionalArguments.first as GetCandidaturasParams;
      return Success(params.page == 1 ? _page(first, last: 2) : _page([_c(11, status: CandidaturaStatus.aprovada)], current: 2, last: 2));
    });
    await pump(tester);

    await tester.drag(find.byType(ListView).last, const Offset(0, -5000));
    await tester.pump();
    await tester.pump();
    await tester.drag(find.byType(ListView).last, const Offset(0, -5000));
    await tester.pumpAndSettle();

    expect(find.text('Vaga 11'), findsOneWidget);
  });

  testWidgets('candidatura enviada em outra tela atualiza a lista', (tester) async {
    stubList([_c(1)]);
    await pump(tester);
    expect(find.text('Vaga 2'), findsNothing);

    stubList([_c(2), _c(1)]);
    notifier.notify(2);
    await tester.pump();
    await tester.pump();

    expect(find.text('Vaga 2'), findsOneWidget);
  });

  group('retirar', () {
    testWidgets('link do card: confirma, retira e avisa; o card some', (tester) async {
      stubList([_c(3), _c(5, status: CandidaturaStatus.aprovada)]);
      when(() => retirar.call(any())).thenAnswer((_) async => const Success(unit));
      await pump(tester);

      await tester.tap(find.text('Retirar candidatura'));
      await tester.pumpAndSettle();
      expect(find.text('Retirar candidatura?'), findsOneWidget);
      verifyNever(() => retirar.call(any()));

      await tester.tap(find.text('Retirar'));
      await tester.pumpAndSettle();

      expect((verify(() => retirar.call(captureAny())).captured.single as CandidaturaIdParams).id, 3);
      expect(find.text('Vaga 3'), findsNothing);
      expect(find.text('Vaga 5'), findsOneWidget);
      expect(find.text('Candidatura retirada.'), findsOneWidget);
    });

    testWidgets('cancelar na confirmação não chama a API', (tester) async {
      stubList([_c(3)]);
      await pump(tester);

      await tester.tap(find.text('Retirar candidatura'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      verifyNever(() => retirar.call(any()));
      expect(find.text('Vaga 3'), findsOneWidget);
    });

    testWidgets('erro da API mantém o card e mostra a mensagem', (tester) async {
      stubList([_c(3)]);
      when(() => retirar.call(any())).thenAnswer((_) async => const Failure(ValidationException(message: 'Só candidaturas enviadas.')));
      await pump(tester);

      await tester.tap(find.text('Retirar candidatura'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirar'));
      await tester.pumpAndSettle();

      expect(find.text('Vaga 3'), findsOneWidget);
      expect(find.text('Só candidaturas enviadas.'), findsOneWidget);
    });

    testWidgets('mostra progresso no card durante a retirada', (tester) async {
      stubList([_c(3)]);
      when(() => retirar.call(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return const Success(unit);
      });
      await pump(tester);

      await tester.tap(find.text('Retirar candidatura'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirar'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Retirar candidatura'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Vaga 3'), findsNothing);
    });
  });

  group('bottom sheet', () {
    testWidgets('toque no card abre o sheet com a mensagem enviada', (tester) async {
      stubList([_c(1, status: CandidaturaStatus.emAnalise)]);
      when(() => getCandidatura.call(any())).thenAnswer((_) async => Success(_c(1, status: CandidaturaStatus.emAnalise, mensagem: 'Tenho 3 anos de Flutter.')));
      await pump(tester);

      await tester.tap(find.text('Vaga 1'));
      await tester.pumpAndSettle();

      expect(find.text('MENSAGEM ENVIADA'), findsOneWidget);
      expect(find.text('Tenho 3 anos de Flutter.'), findsOneWidget);
      expect((verify(() => getCandidatura.call(captureAny())).captured.single as CandidaturaIdParams).id, 1);
      expect(find.text('Retirar candidatura'), findsNothing); // só para "enviada"
    });

    testWidgets('"enviada": retirar pelo sheet fecha, confirma e retira', (tester) async {
      stubList([_c(3)]);
      when(() => getCandidatura.call(any())).thenAnswer((_) async => Success(_c(3, mensagem: 'Mensagem.')));
      when(() => retirar.call(any())).thenAnswer((_) async => const Success(unit));
      await pump(tester);

      await tester.tap(find.text('Vaga 3'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Retirar candidatura'));
      await tester.pumpAndSettle();

      expect(find.text('Retirar candidatura?'), findsOneWidget);

      await tester.tap(find.text('Retirar'));
      await tester.pumpAndSettle();

      expect(find.text('Vaga 3'), findsNothing);
      expect(find.text('Candidatura retirada.'), findsOneWidget);
    });

    testWidgets('erro ao carregar a mensagem oferece tentar de novo', (tester) async {
      stubList([_c(1, status: CandidaturaStatus.aprovada)]);
      var calls = 0;
      when(() => getCandidatura.call(any())).thenAnswer((_) async => ++calls == 1 ? const Failure(NetworkException()) : Success(_c(1, mensagem: 'Agora veio.')));
      await pump(tester);

      await tester.tap(find.text('Vaga 1'));
      await tester.pumpAndSettle();
      expect(find.text('Tentar novamente'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Agora veio.'), findsOneWidget);
    });
  });
}
