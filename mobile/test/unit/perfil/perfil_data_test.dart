import 'package:base_clean_arch_bloc/src/app/features/perfil/data/datasources/perfil_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/data/models/perfil_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/data/repositories/perfil_repository_impl.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/dtos/update_perfil_params.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/errors/unauthorized_exception.dart';
import 'package:base_clean_arch_bloc/src/core/utils/endpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'support.dart';

class MockRestClient extends Mock implements IRestClient {}

class MockPerfilRemoteDatasource extends Mock implements PerfilRemoteDatasource {}

RestClientResponse _response(int status, dynamic data) => RestClientResponse(data: data, statusCode: status, request: RestClientRequest(path: '/x'));

void main() {
  group('PerfilModel', () {
    test('parseia o usuário de GET /me (id inteiro, bio opcional)', () {
      final model = PerfilModel.fromMap(meJson()['data'] as Map<String, dynamic>);

      // Equatable compara o tipo também: o model é comparado pelos campos da entidade.
      expect(model.props, perfilAna.props);
      expect(model.id, 4);
    });

    test('bio nula', () {
      expect(PerfilModel.fromMap(meJson(bio: null)['data'] as Map<String, dynamic>).bio, isNull);
    });

    test('payload inválido lança Exception', () {
      expect(() => PerfilModel.fromMap(const {'id': 'x'}), throwsA(isA<Exception>()));
    });
  });

  group('PerfilRemoteDatasource', () {
    late MockRestClient client;

    setUpAll(() => registerFallbackValue(RestClientRequest(path: '')));

    setUp(() {
      client = MockRestClient();
      when(() => client.get(any())).thenAnswer((_) async => _response(200, meJson()));
      when(() => client.put(any())).thenAnswer((_) async => _response(200, meJson()));
      when(() => client.post(any())).thenAnswer((_) async => _response(204, null));
    });

    test('GET /me', () async {
      await PerfilRemoteDatasource(restClient: client).getMe();

      final request = verify(() => client.get(captureAny())).captured.single as RestClientRequest;
      expect(request.path, Endpoints.me);
    });

    test('PUT /me com a bio no corpo', () async {
      await PerfilRemoteDatasource(restClient: client).updateMe(UpdatePerfilParams(bio: 'Nova bio'));

      final request = verify(() => client.put(captureAny())).captured.single as RestClientRequest;
      expect(request.path, Endpoints.me);
      expect(request.data, {'bio': 'Nova bio'});
    });

    test('POST /auth/logout', () async {
      await PerfilRemoteDatasource(restClient: client).logout();

      final request = verify(() => client.post(captureAny())).captured.single as RestClientRequest;
      expect(request.path, Endpoints.logout);
    });
  });

  group('PerfilRepositoryImpl', () {
    late MockPerfilRemoteDatasource datasource;
    late PerfilRepositoryImpl repository;

    setUpAll(() => registerFallbackValue(UpdatePerfilParams.empty()));

    setUp(() {
      datasource = MockPerfilRemoteDatasource();
      repository = PerfilRepositoryImpl(datasource: datasource);
    });

    test('getPerfil devolve a entidade', () async {
      when(() => datasource.getMe()).thenAnswer((_) async => _response(200, meJson()));

      expect((await repository.getPerfil()).getOrNull()?.props, perfilAna.props);
    });

    test('updatePerfil devolve o perfil atualizado', () async {
      when(() => datasource.updateMe(any())).thenAnswer((_) async => _response(200, meJson(bio: 'Nova')));

      final result = await repository.updatePerfil(UpdatePerfilParams(bio: 'Nova'));

      expect(result.getOrNull()?.bio, 'Nova');
    });

    test('422 vira ValidationException com o erro do campo bio', () async {
      when(() => datasource.updateMe(any())).thenAnswer((_) async => _response(422, {
            'message': 'The bio field must not be greater than 1000 characters.',
            'errors': {
              'bio': ['The bio field must not be greater than 1000 characters.'],
            },
          }));

      final failure = (await repository.updatePerfil(UpdatePerfilParams(bio: 'x'))).exceptionOrNull();

      expect(failure, isA<ValidationException>());
      expect((failure as ValidationException).firstErrorFor('bio'), contains('1000'));
    });

    test('401 vira UnauthorizedException', () async {
      when(() => datasource.getMe()).thenAnswer((_) async => _response(401, {'message': 'Unauthenticated.'}));

      expect((await repository.getPerfil()).exceptionOrNull(), isA<UnauthorizedException>());
    });

    test('logout aceita 204 sem corpo', () async {
      when(() => datasource.logout()).thenAnswer((_) async => _response(204, null));

      expect((await repository.logout()).isSuccess(), isTrue);
    });

    test('falha sem resposta vira NetworkException', () async {
      when(() => datasource.getMe()).thenThrow(RestClientException(message: 'sem conexão', error: 'sem conexão'));

      expect((await repository.getPerfil()).exceptionOrNull(), isA<NetworkException>());
    });

    test('5xx vira DefaultException com o status', () async {
      when(() => datasource.getMe()).thenThrow(RestClientException(message: 'erro', statusCode: 500, error: 'erro'));

      final failure = (await repository.getPerfil()).exceptionOrNull();

      expect(failure, isA<DefaultException>());
      expect((failure as DefaultException).statusCode, 500);
    });

    test('corpo fora do contrato vira DefaultException, sem lançar', () async {
      when(() => datasource.getMe()).thenAnswer((_) async => _response(200, {'data': 1}));

      expect((await repository.getPerfil()).exceptionOrNull(), isA<DefaultException>());
    });
  });
}
