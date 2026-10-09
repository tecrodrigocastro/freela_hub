import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/datasources/candidaturas_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/models/candidaturas_page_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/repositories/candidaturas_repository_impl.dart';
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
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/utils/candidatura_formatters.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/services/candidatura_sent_notifier.dart';
import 'package:base_clean_arch_bloc/src/core/utils/endpoints.dart';
import 'package:base_clean_arch_bloc/src/core/utils/short_date_format.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

class MockRestClient extends Mock implements IRestClient {}

class MockDatasource extends Mock implements CandidaturasRemoteDatasource {}

class MockGetCandidaturas extends Mock implements GetCandidaturasUsecase {}

class MockGetCandidatura extends Mock implements GetCandidaturaUsecase {}

class MockRetirar extends Mock implements RetirarCandidaturaUsecase {}

RestClientResponse _response(int status, dynamic data) => RestClientResponse(data: data, statusCode: status, request: RestClientRequest(path: '/x'));

Map<String, dynamic> _item(int id, {String status = 'enviada', num? valor = 4200}) => {
      'id': id,
      'vaga': {'id': id + 100, 'titulo': 'Vaga $id', 'empresa': 'Clínica Vida'},
      'valor_proposto': valor,
      'status': status,
      'created_at': '2026-10-03T12:00:00Z',
    };

Map<String, dynamic> _listJson({int current = 1, int last = 2, List<int> ids = const [1, 2]}) => {
      'data': [for (final id in ids) _item(id)],
      'links': {'next': null},
      'meta': {'current_page': current, 'last_page': last, 'total': 12},
    };

CandidaturaEntity _c(int id, {CandidaturaStatus status = CandidaturaStatus.enviada}) =>
    CandidaturaEntity(id: id, vagaId: id + 100, vagaTitulo: 'Vaga $id', vagaEmpresa: 'Clínica Vida', valorProposto: 4200, status: status);

CandidaturasPageEntity _page(List<CandidaturaEntity> items, {int current = 1, int last = 1}) =>
    CandidaturasPageEntity(candidaturas: items, currentPage: current, lastPage: last);

void main() {
  setUpAll(() {
    registerFallbackValue(GetCandidaturasParams.empty());
    registerFallbackValue(CandidaturaIdParams.empty());
    registerFallbackValue(RestClientRequest(path: ''));
  });

  group('formatadores', () {
    test('formatShortDate: dia com zero, mês abreviado sem ponto', () {
      expect(formatShortDate(DateTime(2026, 10, 3)), '03 out 2026');
      expect(formatShortDate(DateTime(2026, 9, 28)), '28 set 2026');
      expect(formatShortDate(DateTime(2027, 1, 15)), '15 jan 2027');
    });

    test('CandidaturaFormatters', () {
      final c = CandidaturaEntity(id: 1, vagaId: 1, vagaTitulo: 't', valorProposto: 4200, status: CandidaturaStatus.emAnalise, createdAt: DateTime(2026, 10, 3, 12));

      expect(c.valorLabel, 'R\$ 4.200');
      expect(c.dataLabel, '03 out 2026');
      expect(c.chipType, StatusChipType.emAnalise);
      expect(c.podeRetirar, isFalse);
      expect(_c(1).podeRetirar, isTrue);
      expect(const CandidaturaEntity(id: 1, vagaId: 1, vagaTitulo: 't', status: CandidaturaStatus.recusada).valorLabel, '');
    });
  });

  group('CandidaturasPageModel', () {
    test('parseia itens da lista (sem mensagem) e paginação', () {
      final page = CandidaturasPageModel.fromMap(_listJson());

      expect(page.candidaturas, hasLength(2));
      expect(page.candidaturas.first.vagaTitulo, 'Vaga 1');
      expect(page.candidaturas.first.vagaEmpresa, 'Clínica Vida');
      expect(page.candidaturas.first.mensagem, isNull);
      expect(page.hasMore, isTrue);
    });

    test('valor nulo e status em_analise', () {
      final json = _listJson();
      (json['data'] as List)[0] = _item(1, status: 'em_analise', valor: null);

      final first = CandidaturasPageModel.fromMap(json).candidaturas.first;

      expect(first.valorProposto, isNull);
      expect(first.status, CandidaturaStatus.emAnalise);
    });
  });

  group('datasource', () {
    test('GET lista com page; GET detalhe; DELETE', () async {
      final client = MockRestClient();
      when(() => client.get(any())).thenAnswer((_) async => _response(200, {}));
      when(() => client.delete(any())).thenAnswer((_) async => _response(204, null));
      final datasource = CandidaturasRemoteDatasource(restClient: client);

      await datasource.getCandidaturas(GetCandidaturasParams(page: 3));
      await datasource.getCandidatura(CandidaturaIdParams(id: 7));
      await datasource.retirar(CandidaturaIdParams(id: 7));

      final gets = verify(() => client.get(captureAny())).captured.cast<RestClientRequest>();
      expect(gets[0].path, Endpoints.candidaturas);
      expect(gets[0].queryParameters, {'page': 3});
      expect(gets[1].path, Endpoints.candidatura(7));
      expect((verify(() => client.delete(captureAny())).captured.single as RestClientRequest).path, Endpoints.candidatura(7));
    });
  });

  group('repository', () {
    late MockDatasource datasource;
    late CandidaturasRepositoryImpl repository;

    setUp(() {
      datasource = MockDatasource();
      repository = CandidaturasRepositoryImpl(datasource: datasource);
    });

    test('lista 200', () async {
      when(() => datasource.getCandidaturas(any())).thenAnswer((_) async => _response(200, _listJson()));

      expect((await repository.getCandidaturas(GetCandidaturasParams())).getOrNull()!.candidaturas, hasLength(2));
    });

    test('detalhe traz a mensagem', () async {
      when(() => datasource.getCandidatura(any())).thenAnswer((_) async => _response(200, {
            'data': {..._item(1), 'mensagem': 'Minha mensagem completa.'},
          }));

      expect((await repository.getCandidatura(CandidaturaIdParams(id: 1))).getOrNull()!.mensagem, 'Minha mensagem completa.');
    });

    test('detalhe 403 (candidatura de outro usuário) mantém o status', () async {
      when(() => datasource.getCandidatura(any())).thenAnswer((_) async => _response(403, {'message': 'Sem permissão.'}));

      final failure = (await repository.getCandidatura(CandidaturaIdParams(id: 1))).exceptionOrNull()! as DefaultException;
      expect(failure.statusCode, 403);
    });

    test('retirar 204 sem corpo é sucesso', () async {
      when(() => datasource.retirar(any())).thenAnswer((_) async => _response(204, null));

      expect((await repository.retirar(CandidaturaIdParams(id: 1))).isSuccess(), isTrue);
    });

    test('retirar fora de "enviada": 422 em errors.status vira ValidationException', () async {
      when(() => datasource.retirar(any())).thenAnswer((_) async => _response(422, {
            'message': 'Só é possível retirar candidaturas enviadas.',
            'errors': {
              'status': ['Só é possível retirar candidaturas enviadas.'],
            },
          }));

      final failure = (await repository.retirar(CandidaturaIdParams(id: 1))).exceptionOrNull()! as ValidationException;
      expect(failure.message, 'Só é possível retirar candidaturas enviadas.');
    });

    test('retirar 404 vira NotFoundException com mensagem própria', () async {
      when(() => datasource.retirar(any())).thenAnswer((_) async => _response(404, {'message': 'No query results for model'}));

      final failure = (await repository.retirar(CandidaturaIdParams(id: 1))).exceptionOrNull()! as NotFoundException;
      expect(failure.message, 'Esta candidatura não existe mais.');
    });

    test('sem resposta do servidor vira NetworkException', () async {
      when(() => datasource.getCandidaturas(any())).thenThrow(RestClientException(message: 'timeout', error: 'x'));

      expect((await repository.getCandidaturas(GetCandidaturasParams())).exceptionOrNull(), isA<NetworkException>());
    });
  });

  group('CandidaturasBloc', () {
    late MockGetCandidaturas getCandidaturas;
    late MockRetirar retirar;

    setUp(() {
      getCandidaturas = MockGetCandidaturas();
      retirar = MockRetirar();
    });

    CandidaturasBloc build({CandidaturaSentNotifier? notifier}) =>
        CandidaturasBloc(getCandidaturasUsecase: getCandidaturas, retirarCandidaturaUsecase: retirar, sentNotifier: notifier);

    blocTest<CandidaturasBloc, CandidaturasState>(
      'Started carrega a primeira página',
      build: build,
      setUp: () => when(() => getCandidaturas.call(any())).thenAnswer((_) async => Success(_page([_c(1), _c(2)], last: 2))),
      act: (bloc) => bloc.add(const CandidaturasStarted()),
      expect: () => [const CandidaturasLoading(), CandidaturasLoaded(candidaturas: [_c(1), _c(2)], currentPage: 1, hasMore: true)],
    );

    blocTest<CandidaturasBloc, CandidaturasState>(
      'erro vira CandidaturasFailure',
      build: build,
      setUp: () => when(() => getCandidaturas.call(any())).thenAnswer((_) async => const Failure(NetworkException())),
      act: (bloc) => bloc.add(const CandidaturasStarted()),
      expect: () => [const CandidaturasLoading(), isA<CandidaturasFailure>()],
    );

    blocTest<CandidaturasBloc, CandidaturasState>(
      'Refreshed recarrega sem passar por loading',
      build: build,
      seed: () => CandidaturasLoaded(candidaturas: [_c(1)], currentPage: 1, hasMore: false),
      setUp: () => when(() => getCandidaturas.call(any())).thenAnswer((_) async => Success(_page([_c(9)]))),
      act: (bloc) => bloc.add(const CandidaturasRefreshed()),
      expect: () => [CandidaturasLoaded(candidaturas: [_c(9)], currentPage: 1, hasMore: false)],
    );

    blocTest<CandidaturasBloc, CandidaturasState>(
      'NextPage anexa a página seguinte sem repetir ids',
      build: build,
      seed: () => CandidaturasLoaded(candidaturas: [_c(1), _c(2)], currentPage: 1, hasMore: true),
      setUp: () => when(() => getCandidaturas.call(any())).thenAnswer((_) async => Success(_page([_c(2), _c(3)], current: 2, last: 2))),
      act: (bloc) => bloc.add(const CandidaturasNextPageRequested()),
      expect: () => [
        isA<CandidaturasLoaded>().having((s) => s.isLoadingMore, 'loading', true),
        CandidaturasLoaded(candidaturas: [_c(1), _c(2), _c(3)], currentPage: 2, hasMore: false),
      ],
      verify: (_) => expect((verify(() => getCandidaturas.call(captureAny())).captured.single as GetCandidaturasParams).page, 2),
    );

    blocTest<CandidaturasBloc, CandidaturasState>(
      'retirar com sucesso tira a candidatura da lista e avisa',
      build: build,
      seed: () => CandidaturasLoaded(candidaturas: [_c(1), _c(2)], currentPage: 1, hasMore: false),
      setUp: () => when(() => retirar.call(any())).thenAnswer((_) async => const Success(unit)),
      act: (bloc) => bloc.add(const CandidaturaRetirarRequested(2)),
      expect: () => [
        isA<CandidaturasLoaded>().having((s) => s.removingIds, 'removingIds', {2}),
        isA<CandidaturasLoaded>()
            .having((s) => s.candidaturas.map((c) => c.id), 'ids', [1])
            .having((s) => s.removingIds, 'removingIds', isEmpty)
            .having((s) => s.feedback?.message, 'aviso', 'Candidatura retirada.')
            .having((s) => s.feedback?.isError, 'isError', false),
      ],
      verify: (_) => expect((verify(() => retirar.call(captureAny())).captured.single as CandidaturaIdParams).id, 2),
    );

    blocTest<CandidaturasBloc, CandidaturasState>(
      'retirar com erro mantém a candidatura e mostra a mensagem da API',
      build: build,
      seed: () => CandidaturasLoaded(candidaturas: [_c(1)], currentPage: 1, hasMore: false),
      setUp: () => when(() => retirar.call(any())).thenAnswer((_) async => const Failure(ValidationException(message: 'Só candidaturas enviadas.'))),
      act: (bloc) => bloc.add(const CandidaturaRetirarRequested(1)),
      expect: () => [
        isA<CandidaturasLoaded>().having((s) => s.removingIds, 'removingIds', {1}),
        isA<CandidaturasLoaded>()
            .having((s) => s.candidaturas, 'candidaturas', hasLength(1))
            .having((s) => s.removingIds, 'removingIds', isEmpty)
            .having((s) => s.feedback?.message, 'aviso', 'Só candidaturas enviadas.')
            .having((s) => s.feedback?.isError, 'isError', true),
      ],
    );

    blocTest<CandidaturasBloc, CandidaturasState>(
      'dois avisos iguais seguidos têm ids diferentes (o snackbar reaparece)',
      build: build,
      seed: () => CandidaturasLoaded(candidaturas: [_c(1), _c(2)], currentPage: 1, hasMore: false),
      setUp: () => when(() => retirar.call(any())).thenAnswer((_) async => const Success(unit)),
      act: (bloc) async {
        bloc.add(const CandidaturaRetirarRequested(1));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const CandidaturaRetirarRequested(2));
      },
      verify: (bloc) {
        final state = bloc.state as CandidaturasLoaded;
        expect(state.candidaturas, isEmpty);
        expect(state.feedback!.id, 2);
      },
    );

    test('candidatura nova enviada em outra tela recarrega a lista', () async {
      final notifier = CandidaturaSentNotifier();
      var page = _page([_c(1)]);
      when(() => getCandidaturas.call(any())).thenAnswer((_) async => Success(page));
      final bloc = build(notifier: notifier)..add(const CandidaturasStarted());
      await bloc.stream.firstWhere((s) => s is CandidaturasLoaded);

      page = _page([_c(5), _c(1)]);
      notifier.notify(5);
      final updated = await bloc.stream.firstWhere((s) => s is CandidaturasLoaded && s.candidaturas.length == 2) as CandidaturasLoaded;

      expect(updated.candidaturas.first.id, 5);
      await bloc.close();
    });
  });

  group('CandidaturaDetailBloc', () {
    late MockGetCandidatura getCandidatura;

    setUp(() => getCandidatura = MockGetCandidatura());

    blocTest<CandidaturaDetailBloc, CandidaturaDetailState>(
      'carrega a candidatura completa',
      build: () => CandidaturaDetailBloc(getCandidaturaUsecase: getCandidatura),
      setUp: () => when(() => getCandidatura.call(any())).thenAnswer((_) async => Success(_c(1))),
      act: (bloc) => bloc.add(const CandidaturaDetailStarted(1)),
      expect: () => [const CandidaturaDetailLoading(), CandidaturaDetailLoaded(_c(1))],
    );

    blocTest<CandidaturaDetailBloc, CandidaturaDetailState>(
      'erro permite tentar de novo',
      build: () => CandidaturaDetailBloc(getCandidaturaUsecase: getCandidatura),
      setUp: () {
        var calls = 0;
        when(() => getCandidatura.call(any())).thenAnswer((_) async => ++calls == 1 ? const Failure(NetworkException()) : Success(_c(1)));
      },
      act: (bloc) async {
        bloc.add(const CandidaturaDetailStarted(1));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const CandidaturaDetailStarted(1));
      },
      expect: () => [const CandidaturaDetailLoading(), isA<CandidaturaDetailFailure>(), const CandidaturaDetailLoading(), CandidaturaDetailLoaded(_c(1))],
    );
  });
}
