import 'package:base_clean_arch_bloc/src/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/data/models/auth_response_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/login_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/register_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/entities/auth_response_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/errors/unauthorized_exception.dart';
import 'package:result_dart/result_dart.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDatasource _authRemoteDatasource;

  AuthRepositoryImpl({required AuthRemoteDatasource authRemoteDatasource})
      : _authRemoteDatasource = authRemoteDatasource;

  @override
  AsyncResult<AuthResponseEntity> login(LoginParams params) =>
      _authenticate(() => _authRemoteDatasource.login(params));

  @override
  AsyncResult<AuthResponseEntity> register(RegisterParams params) =>
      _authenticate(() => _authRemoteDatasource.register(params));

  /// O cliente HTTP só lança para 5xx/falha de rede; 4xx chegam como resposta,
  /// então o status é mapeado aqui.
  AsyncResult<AuthResponseEntity> _authenticate(
      Future<RestClientResponse> Function() call) async {
    try {
      final response = await call();
      final status = response.statusCode ?? 0;

      if (status >= 200 && status < 300) {
        return Success(
            AuthResponseModel.fromMap(response.data as Map<String, dynamic>));
      }

      return Failure(mapApiFailure(status, response.data));
    } on RestClientException catch (e) {
      if (e.statusCode == 401) {
        return Failure(UnauthorizedException(message: e.message));
      }
      if (e.statusCode == null) {
        return const Failure(NetworkException());
      }
      return Failure(
          DefaultException(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Failure(
          DefaultException(message: 'Erro inesperado: ${e.toString()}'));
    }
  }
}
