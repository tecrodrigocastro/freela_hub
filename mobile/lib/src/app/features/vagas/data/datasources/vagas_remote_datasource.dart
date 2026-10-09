import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vaga_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vagas_params.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/utils/endpoints.dart';

class VagasRemoteDatasource {
  final IRestClient _restClient;

  VagasRemoteDatasource({required IRestClient restClient}) : _restClient = restClient;

  Future<RestClientResponse> getVagas(GetVagasParams params) => //
      _restClient.get(
        RestClientRequest(
          path: Endpoints.vagas,
          queryParameters: params.toJson(),
        ),
      );

  Future<RestClientResponse> getVaga(GetVagaParams params) => //
      _restClient.get(RestClientRequest(path: Endpoints.vaga(params.id)));

  Future<RestClientResponse> getCategorias() => //
      _restClient.get(RestClientRequest(path: Endpoints.categorias));
}
