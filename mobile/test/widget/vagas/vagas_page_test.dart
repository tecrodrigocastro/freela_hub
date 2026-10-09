import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vagas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/categoria_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_categorias_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vagas_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vagas_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/pages/vagas_page.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../unit/vagas/support.dart';

class MockGetVagasUsecase extends Mock implements GetVagasUsecase {}

class MockGetCategoriasUsecase extends Mock implements GetCategoriasUsecase {}

void main() {
  late MockGetVagasUsecase getVagas;
  late MockGetCategoriasUsecase getCategorias;

  setUpAll(() {
    registerFallbackValue(GetVagasParams.empty());
    registerFallbackValue(NoParams());
  });

  setUp(() {
    getVagas = MockGetVagasUsecase();
    getCategorias = MockGetCategoriasUsecase();
    when(() => getCategorias.call(any())).thenAnswer(
      (_) async => const Success([categoriaMobile, CategoriaEntity(id: 1, nome: 'Desenvolvimento Web')]),
    );
    injector.registerFactory(() => VagasBloc(getVagasUsecase: getVagas, getCategoriasUsecase: getCategorias));
  });

  tearDown(() => injector.reset());

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const VagasPage()));
    await tester.pump();
    await tester.pump();
  }

  Finder chip(String label) => find.widgetWithText(FilterChipItem, label, skipOffstage: false);

  GetVagasParams lastParams() => verify(() => getVagas.call(captureAny())).captured.last as GetVagasParams;

  testWidgets('mostra título, busca, chips e os cards da primeira página', (tester) async {
    when(() => getVagas.call(any())).thenAnswer(
      (_) async => Success(page([vaga(1), vaga(2, titulo: 'API Laravel', tipo: TipoPagamento.hora, min: 90, max: 130, jaCandidatou: true)])),
    );

    await pump(tester);

    expect(find.text('Vagas'), findsOneWidget);
    expect(find.text('Buscar por título ou descrição'), findsOneWidget);
    expect(find.text('Categoria'), findsOneWidget);
    for (final label in ['Todas', 'Remoto', 'Híbrido']) {
      expect(chip(label), findsOneWidget);
    }
    expect(chip('Presencial'), findsOneWidget); // fica além da borda: a barra de chips rola na horizontal
    expect(find.text('App Flutter para clínica'), findsOneWidget);
    expect(find.text('R\$ 3.000 – R\$ 5.000'), findsOneWidget);
    expect(find.text('45 dias'), findsWidgets);
    expect(find.text('R\$ 90 – R\$ 130 /hora'), findsOneWidget);
    expect(find.text('Candidatado'), findsOneWidget); // só na vaga com ja_candidatou
  });

  testWidgets('mostra skeletons enquanto carrega', (tester) async {
    when(() => getVagas.call(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(seconds: 1));
      return Success(page([vaga(1)]));
    });

    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const VagasPage()));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SkeletonCard), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('App Flutter para clínica'), findsOneWidget);
  });

  testWidgets('chip de modalidade recarrega a lista filtrada', (tester) async {
    when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(1)])));
    await pump(tester);

    await tester.tap(chip('Remoto'));
    await tester.pump();
    await tester.pump();

    final params = lastParams();
    expect(params.modalidade, Modalidade.remoto);
    expect(params.page, 1);
  });

  testWidgets('busca com debounce envia q uma única vez', (tester) async {
    when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(1)])));
    await pump(tester);
    clearInteractions(getVagas);

    await tester.enterText(find.byType(TextField), 'fl');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'flutter');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    final params = verify(() => getVagas.call(captureAny())).captured.cast<GetVagasParams>();
    expect(params, hasLength(1));
    expect(params.single.query, 'flutter');
  });

  testWidgets('categoria: bottom sheet lista as categorias e aplica a escolhida', (tester) async {
    when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(1)])));
    await pump(tester);

    await tester.tap(find.text('Categoria'));
    await tester.pumpAndSettle();
    expect(find.text('Todas as categorias'), findsOneWidget);

    await tester.tap(find.text('Desenvolvimento Web'));
    await tester.pumpAndSettle();

    expect(lastParams().categoriaId, 1);
    expect(find.text('Desenvolvimento Web'), findsOneWidget); // chip agora mostra a categoria
  });

  testWidgets('sem resultados: estado vazio com "Limpar filtros"', (tester) async {
    when(() => getVagas.call(any())).thenAnswer((invocation) async {
      final params = invocation.positionalArguments.first as GetVagasParams;
      return Success(params.modalidade == null ? page([vaga(1)]) : page([]));
    });
    await pump(tester);

    await tester.ensureVisible(chip('Presencial'));
    await tester.pumpAndSettle();
    await tester.tap(chip('Presencial'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Nenhuma vaga encontrada'), findsOneWidget);

    await tester.tap(find.text('Limpar filtros'));
    await tester.pump();
    await tester.pump();

    expect(find.text('App Flutter para clínica'), findsOneWidget);
    expect(lastParams().modalidade, isNull);
  });

  testWidgets('erro mostra retry e recarrega', (tester) async {
    var calls = 0;
    when(() => getVagas.call(any())).thenAnswer((_) async {
      calls++;
      return calls == 1 ? const Failure(NetworkException()) : Success(page([vaga(1)]));
    });
    await pump(tester);

    expect(find.text('Não foi possível carregar'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();
    await tester.pump();

    expect(find.text('App Flutter para clínica'), findsOneWidget);
  });

  testWidgets('scroll até o fim carrega a próxima página', (tester) async {
    final first = [for (var i = 1; i <= 10; i++) vaga(i, titulo: 'Vaga $i')];
    when(() => getVagas.call(any())).thenAnswer((invocation) async {
      final params = invocation.positionalArguments.first as GetVagasParams;
      return params.page == 1
          ? Success(page(first, last: 2))
          : Success(page([vaga(11, titulo: 'Vaga 11')], current: 2, last: 2));
    });
    await pump(tester);

    await tester.drag(find.byType(ListView).last, const Offset(0, -5000));
    await tester.pump();
    await tester.pump();
    await tester.drag(find.byType(ListView).last, const Offset(0, -5000));
    await tester.pumpAndSettle();

    expect(find.text('Vaga 11'), findsOneWidget);
    expect(lastParams().page, 2);
  });

  testWidgets('pull-to-refresh recarrega a primeira página', (tester) async {
    when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(1)])));
    await pump(tester);
    clearInteractions(getVagas);

    await tester.fling(find.byType(ListView).last, const Offset(0, 400), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    verify(() => getVagas.call(any())).called(1);
  });
}
