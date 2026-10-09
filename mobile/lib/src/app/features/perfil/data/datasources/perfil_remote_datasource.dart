import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/dtos/update_perfil_params.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/utils/endpoints.dart';

class PerfilRemoteDatasource {
  final IRestClient _restClient;

  PerfilRemoteDatasource({required IRestClient restClient})
      : _restClient = restClient;

  Future<RestClientResponse> getMe() => //
      _restClient.get(RestClientRequest(path: Endpoints.me));

  Future<RestClientResponse> updateMe(UpdatePerfilParams params) => //
      _restClient
          .put(RestClientRequest(path: Endpoints.me, data: params.toJson()));

  Future<RestClientResponse> logout() => //
      _restClient.post(RestClientRequest(path: Endpoints.logout));
}
