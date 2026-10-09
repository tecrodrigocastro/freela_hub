import 'package:base_clean_arch_bloc/src/app/features/vagas/data/datasources/vagas_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/data/models/vaga_detail_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/data/models/vagas_page_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/data/repositories/vagas_repository_impl.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vaga_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vagas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/errors/unauthorized_exception.dart';
import 'package:base_clean_arch_bloc/src/core/utils/endpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support.dart';

class MockRestClient extends Mock implements IRestClient {}

class MockVagasRemoteDatasource extends Mock implements VagasRemoteDatasource {}

RestClientResponse _response(int status, dynamic data) => RestClientResponse(data: data, statusCode: status, request: RestClientRequest(path: '/x'));

void main() {
  group('VagasPageModel', () {
    test('parseia a resposta da API (inteiros e nulos nos valores)', () {
      final result = VagasPageModel.fromMap(vagasJson());

      expect(result.currentPage, 1);
      expect(result.hasMore, isTrue);
      expect(result.vagas, hasLength(2));

      final first = result.vagas.first;
      expect(first.id, 12);
      expect(first.valorMin, 3000.0);
      expect(first.valorMax, 5000.5);
      expect(first.modalidade, Modalidade.remoto);
      expect(first.jaCandidatou, isTrue);

      final second = result.vagas.last;
      expect(second.tipoPagamento, TipoPagamento.hora);
      expect(second.valorMin, isNull);
      expect(second.prazoDias, isNull);
      expect(second.jaCandidatou, isFalse);
    });

    test('última página não tem próxima', () {
      expect(VagasPageModel.fromMap(vagasJson(current: 2)).hasMore, isFalse);
    });

    test('payload inválido lança Exception', () {
      expect(() => VagasPageModel.fromMap(const {'data': 1}), throwsA(isA<Exception>()));
    });
  });

  group('GetVagasParams', () {
    test('toJson só envia o que foi preenchido', () {
      expect(GetVagasParams().toJson(), {'page': 1});
      expect(
        GetVagasParams(query: '  flutter ', categoriaId: 2, modalidade: Modalidade.hibrido, page: 3).toJson(),
        {'q': 'flutter', 'categoria_id': 2, 'modalidade': 'hibrido', 'page': 3},
      );
    });
  });

  group('VagasRemoteDatasource', () {
    setUpAll(() => registerFallbackValue(RestClientRequest(path: '')));

    test('GET /vagas com a query string dos filtros', () async {
      final client = MockRestClient();
      when(() => client.get(any())).thenAnswer((_) async => _response(200, vagasJson()));

      await VagasRemoteDatasource(restClient: client).getVagas(GetVagasParams(query: 'app', page: 2));

      final request = verify(() => client.get(captureAny())).captured.single as RestClientRequest;
      expect(request.path, Endpoints.vagas);
      expect(request.queryParameters, {'q': 'app', 'page': 2});
    });
  });

  group('VagaDetailModel', () {
    test('parseia campos da lista + descrição e total', () {
      final vaga = VagaDetailModel.fromMap(vagaDetailJson()['data'] as Map<String, dynamic>);

      expect(vaga.id, 12);
      expect(vaga.valorMax, 5000.0);
      expect(vaga.descricao, 'Texto completo.');
      expect(vaga.totalCandidaturas, 7);
    });

    test('descrição e total ausentes viram vazio e zero', () {
      final map = Map<String, dynamic>.from(vagaDetailJson()['data'] as Map)..remove('descricao')..remove('total_candidaturas');

      final vaga = VagaDetailModel.fromMap(map);

      expect(vaga.descricao, '');
      expect(vaga.totalCandidaturas, 0);
    });
  });

  group('VagasRepositoryImpl', () {
    late MockVagasRemoteDatasource datasource;
    late VagasRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(GetVagasParams.empty());
      registerFallbackValue(GetVagaParams.empty());
    });

    setUp(() {
      datasource = MockVagasRemoteDatasource();
      repository = VagasRepositoryImpl(datasource: datasource);
    });

    test('getVagas 200 devolve a página', () async {
      when(() => datasource.getVagas(any())).thenAnswer((_) async => _response(200, vagasJson()));

      final result = await repository.getVagas(GetVagasParams());

      expect(result.getOrNull()!.vagas, hasLength(2));
    });

    test('getCategorias 200 devolve as categorias', () async {
      when(() => datasource.getCategorias()).thenAnswer((_) async => _response(200, {
            'data': [
              {'id': 1, 'nome': 'Desenvolvimento Web', 'slug': 'desenvolvimento-web'},
            ],
          }));

      final result = await repository.getCategorias();

      expect(result.getOrNull()!.single.nome, 'Desenvolvimento Web');
    });

    test('401 vira UnauthorizedException', () async {
      when(() => datasource.getVagas(any())).thenAnswer((_) async => _response(401, {'message': 'Unauthenticated.'}));

      expect((await repository.getVagas(GetVagasParams())).exceptionOrNull(), isA<UnauthorizedException>());
    });

    test('outro 4xx vira DefaultException com o status', () async {
      when(() => datasource.getVagas(any())).thenAnswer((_) async => _response(403, {'message': 'Sem permissão.'}));

      final failure = (await repository.getVagas(GetVagasParams())).exceptionOrNull()! as DefaultException;
      expect(failure.statusCode, 403);
      expect(failure.message, 'Sem permissão.');
    });

    test('falha sem resposta vira NetworkException', () async {
      when(() => datasource.getVagas(any())).thenThrow(RestClientException(message: 'timeout', error: 'x'));

      expect((await repository.getVagas(GetVagasParams())).exceptionOrNull(), isA<NetworkException>());
    });

    test('getVaga 200 devolve o detalhe', () async {
      when(() => datasource.getVaga(any())).thenAnswer((_) async => _response(200, vagaDetailJson()));

      final vaga = (await repository.getVaga(GetVagaParams(id: 12))).getOrNull()!;

      expect(vaga.descricao, 'Texto completo.');
      expect(vaga.totalCandidaturas, 7);
      expect(vaga.titulo, 'App Flutter para clínica');
    });

    test('getVaga 404 vira NotFoundException com mensagem própria (não a técnica da API)', () async {
      when(() => datasource.getVaga(any())).thenAnswer(
        (_) async => _response(404, {'message': 'No query results for model [App\\Models\\Vaga] 99'}),
      );

      final failure = (await repository.getVaga(GetVagaParams(id: 99))).exceptionOrNull()! as NotFoundException;

      expect(failure.message, 'Esta vaga não está mais disponível.');
    });

    test('404 na listagem não é "vaga indisponível"', () async {
      when(() => datasource.getVagas(any())).thenAnswer((_) async => _response(404, {'message': 'Not Found'}));

      expect((await repository.getVagas(GetVagasParams())).exceptionOrNull(), isA<DefaultException>());
    });

    test('payload quebrado vira DefaultException (não lança)', () async {
      when(() => datasource.getVagas(any())).thenAnswer((_) async => _response(200, <String, dynamic>{'data': 'x'}));

      expect((await repository.getVagas(GetVagasParams())).exceptionOrNull(), isA<DefaultException>());
    });
  });
}
