import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/datasources/candidaturas_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/models/candidatura_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/models/candidaturas_page_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/candidatura_id_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/enviar_candidatura_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/get_candidaturas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidaturas_page_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/repositories/candidaturas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:result_dart/result_dart.dart';

class CandidaturasRepositoryImpl implements ICandidaturasRepository {
  static const _vagaIndisponivel = 'Esta vaga não está mais disponível.';
  static const _candidaturaIndisponivel = 'Esta candidatura não existe mais.';

  final CandidaturasRemoteDatasource _datasource;

  CandidaturasRepositoryImpl({required CandidaturasRemoteDatasource datasource}) : _datasource = datasource;

  @override
  AsyncResult<CandidaturaEntity> enviar(EnviarCandidaturaParams params) => //
      _request(
        () => _datasource.enviar(params),
        (body) => CandidaturaModel.fromMap(body['data'] as Map<String, dynamic>),
        notFoundMessage: _vagaIndisponivel,
      );

  @override
  AsyncResult<CandidaturasPageEntity> getCandidaturas(GetCandidaturasParams params) => //
      _request(() => _datasource.getCandidaturas(params), CandidaturasPageModel.fromMap);

  @override
  AsyncResult<CandidaturaEntity> getCandidatura(CandidaturaIdParams params) => //
      _request(
        () => _datasource.getCandidatura(params),
        (body) => CandidaturaModel.fromMap(body['data'] as Map<String, dynamic>),
        notFoundMessage: _candidaturaIndisponivel,
      );

  /// `DELETE` responde 204 sem corpo.
  @override
  AsyncResult<Unit> retirar(CandidaturaIdParams params) => //
      _request(() => _datasource.retirar(params), (_) => unit, notFoundMessage: _candidaturaIndisponivel, expectsBody: false);

  /// 4xx chegam como resposta (não lançam); falha sem resposta vira [NetworkException].
  AsyncResult<T> _request<T extends Object>(
    Future<RestClientResponse> Function() call,
    T Function(Map<String, dynamic> body) parse, {
    String? notFoundMessage,
    bool expectsBody = true,
  }) async {
    try {
      final response = await call();
      final status = response.statusCode ?? 0;

      if (status >= 200 && status < 300) {
        return Success(parse(expectsBody ? response.data as Map<String, dynamic> : const {}));
      }

      return Failure(mapApiFailure(status, response.data, notFoundMessage: notFoundMessage));
    } on RestClientException catch (e) {
      if (e.statusCode == null) return const Failure(NetworkException());
      return Failure(DefaultException(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Failure(DefaultException(message: 'Erro inesperado: ${e.toString()}'));
    }
  }
}
