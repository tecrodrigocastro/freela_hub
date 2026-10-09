import 'package:base_clean_arch_bloc/src/app/features/perfil/data/datasources/perfil_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/data/models/perfil_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/dtos/update_perfil_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/entities/perfil_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/repositories/perfil_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:result_dart/result_dart.dart';

class PerfilRepositoryImpl implements IPerfilRepository {
  final PerfilRemoteDatasource _datasource;

  PerfilRepositoryImpl({required PerfilRemoteDatasource datasource})
      : _datasource = datasource;

  @override
  AsyncResult<PerfilEntity> getPerfil() => //
      _request(_datasource.getMe, _parsePerfil);

  @override
  AsyncResult<PerfilEntity> updatePerfil(UpdatePerfilParams params) => //
      _request(() => _datasource.updateMe(params), _parsePerfil);

  @override
  AsyncResult<Unit> logout() => //
      _request(_datasource.logout, (_) => unit);

  PerfilEntity _parsePerfil(dynamic body) => PerfilModel.fromMap(
      (body as Map<String, dynamic>)['data'] as Map<String, dynamic>);

  /// 4xx chegam como resposta (não lançam); falha sem resposta vira [NetworkException].
  /// O logout responde 204 sem corpo, por isso `parse` recebe o corpo cru.
  AsyncResult<T> _request<T extends Object>(
    Future<RestClientResponse> Function() call,
    T Function(dynamic body) parse,
  ) async {
    try {
      final response = await call();
      final status = response.statusCode ?? 0;

      if (status >= 200 && status < 300) return Success(parse(response.data));

      return Failure(mapApiFailure(status, response.data));
    } on RestClientException catch (e) {
      if (e.statusCode == null) return const Failure(NetworkException());
      return Failure(
          DefaultException(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Failure(
          DefaultException(message: 'Erro inesperado: ${e.toString()}'));
    }
  }
}
