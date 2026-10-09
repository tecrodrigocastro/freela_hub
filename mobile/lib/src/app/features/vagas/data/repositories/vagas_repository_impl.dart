import 'package:base_clean_arch_bloc/src/app/features/vagas/data/datasources/vagas_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/data/models/categoria_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/data/models/vaga_detail_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/data/models/vagas_page_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vaga_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vagas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/categoria_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_detail_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vagas_page_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/repositories/vagas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/errors/unauthorized_exception.dart';
import 'package:result_dart/result_dart.dart';

class VagasRepositoryImpl implements IVagasRepository {
  final VagasRemoteDatasource _datasource;

  VagasRepositoryImpl({required VagasRemoteDatasource datasource}) : _datasource = datasource;

  @override
  AsyncResult<VagasPageEntity> getVagas(GetVagasParams params) => //
      _request(() => _datasource.getVagas(params), (data) => VagasPageModel.fromMap(data));

  @override
  AsyncResult<VagaDetailEntity> getVaga(GetVagaParams params) => //
      _request(
        () => _datasource.getVaga(params),
        (data) => VagaDetailModel.fromMap(data['data'] as Map<String, dynamic>),
        notFoundMessage: 'Esta vaga não está mais disponível.',
      );

  @override
  AsyncResult<List<CategoriaEntity>> getCategorias() => //
      _request(
        _datasource.getCategorias,
        (data) => [for (final item in data['data'] as List) CategoriaModel.fromMap(item as Map<String, dynamic>)],
      );

  /// 4xx chegam como resposta (não lançam); falha sem resposta vira [NetworkException].
  AsyncResult<T> _request<T extends Object>(
    Future<RestClientResponse> Function() call,
    T Function(Map<String, dynamic> data) parse, {
    String? notFoundMessage,
  }) async {
    try {
      final response = await call();
      final status = response.statusCode ?? 0;

      if (status >= 200 && status < 300) {
        return Success(parse(response.data as Map<String, dynamic>));
      }

      final body = response.data;
      final message = body is Map ? body['message'] as String? : null;
      if (status == 404 && notFoundMessage != null) {
        // A mensagem da API é técnica (nome do model): mostramos a nossa.
        return Failure(NotFoundException(message: notFoundMessage));
      }
      if (status == 401) {
        return Failure(UnauthorizedException(message: message ?? 'Sessão expirada. Entre novamente.'));
      }
      return Failure(DefaultException(message: message ?? 'Não foi possível carregar as vagas.', statusCode: status));
    } on RestClientException catch (e) {
      if (e.statusCode == null) return const Failure(NetworkException());
      return Failure(DefaultException(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Failure(DefaultException(message: 'Erro inesperado: ${e.toString()}'));
    }
  }
}
