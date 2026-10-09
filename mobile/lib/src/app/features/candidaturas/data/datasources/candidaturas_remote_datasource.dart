import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/candidatura_id_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/enviar_candidatura_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/get_candidaturas_params.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/utils/endpoints.dart';

class CandidaturasRemoteDatasource {
  final IRestClient _restClient;

  CandidaturasRemoteDatasource({required IRestClient restClient}) : _restClient = restClient;

  Future<RestClientResponse> enviar(EnviarCandidaturaParams params) => //
      _restClient.post(
        RestClientRequest(
          path: Endpoints.candidatarVaga(params.vagaId),
          data: params.toJson(),
        ),
      );

  Future<RestClientResponse> getCandidaturas(GetCandidaturasParams params) => //
      _restClient.get(
        RestClientRequest(
          path: Endpoints.candidaturas,
          queryParameters: params.toJson(),
        ),
      );

  Future<RestClientResponse> getCandidatura(CandidaturaIdParams params) => //
      _restClient.get(RestClientRequest(path: Endpoints.candidatura(params.id)));

  Future<RestClientResponse> retirar(CandidaturaIdParams params) => //
      _restClient.delete(RestClientRequest(path: Endpoints.candidatura(params.id)));
}
