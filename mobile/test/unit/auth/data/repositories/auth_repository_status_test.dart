import 'package:base_clean_arch_bloc/src/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/login_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/register_params.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

RestClientResponse _response(int status, dynamic data) => RestClientResponse(
      data: data,
      statusCode: status,
      request: RestClientRequest(path: '/test'),
    );

void main() {
  late MockAuthRemoteDatasource datasource;
  late AuthRepositoryImpl repository;
  final login = LoginParams(email: 'a@a.com', password: 'x');
  final register = RegisterParams(name: 'Ana', email: 'a@a.com', password: 'secret123', passwordConfirmation: 'secret123');

  setUpAll(() {
    registerFallbackValue(login);
    registerFallbackValue(register);
  });

  setUp(() {
    datasource = MockAuthRemoteDatasource();
    repository = AuthRepositoryImpl(authRemoteDatasource: datasource);
  });

  test('register 201 devolve token e usuário (id numérico da API)', () async {
    when(() => datasource.register(any())).thenAnswer(
      (_) async => _response(201, {
        'token': '1|abc',
        'user': {'id': 4, 'name': 'Ana', 'email': 'a@a.com', 'role': 'freelancer', 'bio': null},
      }),
    );

    final result = await repository.register(register);

    expect(result.isSuccess(), isTrue);
    expect(result.getOrNull()!.token, '1|abc');
    expect(result.getOrNull()!.user.id, '4');
  });

  test('422 vira ValidationException com erros por campo', () async {
    when(() => datasource.login(any())).thenAnswer(
      (_) async => _response(422, {
        'message': 'The given data was invalid.',
        'errors': {
          'email': ['Credenciais inválidas.'],
        },
      }),
    );

    final failure = (await repository.login(login)).exceptionOrNull()! as ValidationException;

    expect(failure.message, 'Credenciais inválidas.');
    expect(failure.firstErrorFor('email'), 'Credenciais inválidas.');
  });

  test('403 (usuário que não é freelancer) vira DefaultException com a mensagem da API', () async {
    when(() => datasource.login(any())).thenAnswer((_) async => _response(403, {'message': 'Acesso restrito a freelancers.'}));

    final failure = (await repository.login(login)).exceptionOrNull()! as DefaultException;

    expect(failure.statusCode, 403);
    expect(failure.message, 'Acesso restrito a freelancers.');
  });

  test('falha sem resposta do servidor vira NetworkException', () async {
    when(() => datasource.register(any())).thenThrow(RestClientException(message: 'timeout', error: 'x'));

    final failure = (await repository.register(register)).exceptionOrNull();

    expect(failure, isA<NetworkException>());
  });
}
