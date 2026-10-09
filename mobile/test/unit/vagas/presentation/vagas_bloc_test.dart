import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vagas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vagas_filter_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_categorias_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vagas_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vagas_bloc.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/services/candidatura_sent_notifier.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../support.dart';

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
    when(() => getCategorias.call(any())).thenAnswer((_) async => const Success([categoriaMobile]));
  });

  VagasBloc build() => VagasBloc(getVagasUsecase: getVagas, getCategoriasUsecase: getCategorias);

  group('VagasStarted', () {
    blocTest<VagasBloc, VagasState>(
      'carrega categorias e a primeira página',
      build: build,
      setUp: () => when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(1), vaga(2)], last: 3))),
      act: (bloc) => bloc.add(const VagasStarted()),
      expect: () => [
        const VagasLoading(),
        VagasLoaded(vagas: [vaga(1), vaga(2)], currentPage: 1, hasMore: true, categorias: const [categoriaMobile]),
      ],
    );

    blocTest<VagasBloc, VagasState>(
      'falha de categorias não derruba a lista',
      build: build,
      setUp: () {
        when(() => getCategorias.call(any())).thenAnswer((_) async => const Failure(NetworkException()));
        when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(1)])));
      },
      act: (bloc) => bloc.add(const VagasStarted()),
      expect: () => [
        const VagasLoading(),
        VagasLoaded(vagas: [vaga(1)], currentPage: 1, hasMore: false, categoriasFailed: true),
      ],
    );

    blocTest<VagasBloc, VagasState>(
      'erro na lista emite VagasFailure',
      build: build,
      setUp: () => when(() => getVagas.call(any())).thenAnswer((_) async => const Failure(NetworkException())),
      act: (bloc) => bloc.add(const VagasStarted()),
      expect: () => [
        const VagasLoading(),
        isA<VagasFailure>().having((s) => s.exception, 'exception', isA<NetworkException>()),
      ],
    );
  });

  group('VagasFilterChanged', () {
    const filter = VagasFilterEntity(query: 'flutter', categoriaId: 2, modalidade: Modalidade.remoto);

    blocTest<VagasBloc, VagasState>(
      'recarrega a página 1 enviando os filtros',
      build: build,
      setUp: () => when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(7)]))),
      act: (bloc) => bloc.add(const VagasFilterChanged(filter)),
      expect: () => [
        const VagasLoading(filter: filter),
        VagasLoaded(vagas: [vaga(7)], currentPage: 1, hasMore: false, filter: filter),
      ],
      verify: (_) {
        final params = verify(() => getVagas.call(captureAny())).captured.single as GetVagasParams;
        expect(params, GetVagasParams(query: 'flutter', categoriaId: 2, modalidade: Modalidade.remoto));
      },
    );

    blocTest<VagasBloc, VagasState>(
      'filtros novos descartam a resposta atrasada da busca anterior',
      build: build,
      setUp: () {
        when(() => getVagas.call(any())).thenAnswer((invocation) async {
          final params = invocation.positionalArguments.first as GetVagasParams;
          if (params.query == 'lenta') {
            await Future<void>.delayed(const Duration(milliseconds: 80));
            return Success(page([vaga(1, titulo: 'lenta')]));
          }
          return Success(page([vaga(2, titulo: 'rapida')]));
        });
      },
      act: (bloc) async {
        bloc.add(const VagasFilterChanged(VagasFilterEntity(query: 'lenta')));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const VagasFilterChanged(VagasFilterEntity(query: 'rapida')));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final state = bloc.state as VagasLoaded;
        expect(state.vagas.single.titulo, 'rapida');
        expect(state.filter.query, 'rapida');
      },
    );
  });

  group('VagasNextPageRequested', () {
    final loaded = VagasLoaded(vagas: [vaga(1), vaga(2)], currentPage: 1, hasMore: true);

    blocTest<VagasBloc, VagasState>(
      'anexa a próxima página e ignora ids repetidos',
      build: build,
      seed: () => loaded,
      setUp: () => when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(2), vaga(3)], current: 2, last: 2))),
      act: (bloc) => bloc.add(const VagasNextPageRequested()),
      expect: () => [
        loaded.copyWith(isLoadingMore: true),
        VagasLoaded(vagas: [vaga(1), vaga(2), vaga(3)], currentPage: 2, hasMore: false),
      ],
      verify: (_) {
        final params = verify(() => getVagas.call(captureAny())).captured.single as GetVagasParams;
        expect(params.page, 2);
      },
    );

    blocTest<VagasBloc, VagasState>(
      'erro mantém a lista e guarda o erro para retry',
      build: build,
      seed: () => loaded,
      setUp: () => when(() => getVagas.call(any())).thenAnswer((_) async => const Failure(NetworkException())),
      act: (bloc) => bloc.add(const VagasNextPageRequested()),
      expect: () => [
        loaded.copyWith(isLoadingMore: true),
        isA<VagasLoaded>().having((s) => s.vagas, 'vagas', loaded.vagas).having((s) => s.loadMoreError, 'erro', isA<NetworkException>()).having((s) => s.isLoadingMore, 'loading', false),
      ],
    );

    blocTest<VagasBloc, VagasState>(
      'não busca quando não há mais páginas',
      build: build,
      seed: () => VagasLoaded(vagas: [vaga(1)], currentPage: 1, hasMore: false),
      act: (bloc) => bloc.add(const VagasNextPageRequested()),
      expect: () => <VagasState>[],
      verify: (_) => verifyNever(() => getVagas.call(any())),
    );

    blocTest<VagasBloc, VagasState>(
      'chamadas repetidas durante o carregamento viram uma só',
      build: build,
      seed: () => loaded,
      setUp: () => when(() => getVagas.call(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return Success(page([vaga(3)], current: 2, last: 2));
      }),
      act: (bloc) {
        bloc
          ..add(const VagasNextPageRequested())
          ..add(const VagasNextPageRequested())
          ..add(const VagasNextPageRequested());
      },
      wait: const Duration(milliseconds: 100),
      verify: (_) => verify(() => getVagas.call(any())).called(1),
    );
  });

  group('VagasRefreshed', () {
    blocTest<VagasBloc, VagasState>(
      'recarrega com o filtro atual sem trocar a lista por skeleton',
      build: build,
      seed: () => VagasLoaded(vagas: [vaga(1)], currentPage: 2, hasMore: true, filter: const VagasFilterEntity(query: 'app')),
      setUp: () => when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(9)]))),
      act: (bloc) => bloc.add(const VagasRefreshed()),
      expect: () => [
        VagasLoaded(vagas: [vaga(9)], currentPage: 1, hasMore: false, filter: const VagasFilterEntity(query: 'app')),
      ],
    );
  });

  group('VagasCategoriasRequested', () {
    blocTest<VagasBloc, VagasState>(
      'tenta de novo as categorias',
      build: build,
      seed: () => const VagasLoaded(vagas: [], currentPage: 1, hasMore: false, categoriasFailed: true),
      act: (bloc) => bloc.add(const VagasCategoriasRequested()),
      expect: () => [const VagasLoaded(vagas: [], currentPage: 1, hasMore: false, categorias: [categoriaMobile])],
    );
  });

  group('candidatura enviada em outra tela', () {
    test('marca a vaga como candidatado sem recarregar a lista', () async {
      final notifier = CandidaturaSentNotifier();
      final bloc = VagasBloc(getVagasUsecase: getVagas, getCategoriasUsecase: getCategorias, sentNotifier: notifier);
      when(() => getVagas.call(any())).thenAnswer((_) async => Success(page([vaga(1), vaga(2)])));
      bloc.add(const VagasStarted());
      await bloc.stream.firstWhere((s) => s is VagasLoaded);
      clearInteractions(getVagas);

      notifier.notify(2);
      final updated = await bloc.stream.firstWhere((s) => s is VagasLoaded && s.vagas.any((v) => v.jaCandidatou)) as VagasLoaded;

      expect(updated.vagas.map((v) => v.jaCandidatou), [false, true]);
      verifyNever(() => getVagas.call(any()));
      await bloc.close();
    });

    test('ignora enquanto a lista não está carregada e para de ouvir ao fechar', () async {
      final notifier = CandidaturaSentNotifier();
      final bloc = VagasBloc(getVagasUsecase: getVagas, getCategoriasUsecase: getCategorias, sentNotifier: notifier);

      notifier.notify(1);
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<VagasInitial>());

      await bloc.close();
      notifier.notify(1); // não deve lançar (bloc fechado)
    });
  });
}
