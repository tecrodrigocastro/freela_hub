import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/dio/dio_adapter.dart';
import 'package:dio/dio.dart';

class ClientInterceptorDioImpl implements Interceptor {
  final IClientInterceptor interceptor;

  ClientInterceptorDioImpl({required this.interceptor});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final restClientHttp = DioAdapter.toClientException(err);
    final message = await interceptor.onError(restClientHttp);

    if (message is RestClientException) {
      handler.next(DioAdapter.toDioException(message));
    } else if (message is RestClientResponse) {
      handler.resolve(DioAdapter.toResponse(message));
    }
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final restRequest = DioAdapter.toClientRequest(options);
    final message = await interceptor.onRequest(restRequest);

    //log('onRequest: $message');

    if (message is RestClientException) {
      handler.reject(DioAdapter.toDioException(message));
    } else if (message is RestClientRequest) {
      // copyWith (e não RequestOptions novo) preserva validateStatus, timeouts etc. do Dio:
      // sem isso, qualquer interceptor de request faria 4xx virarem exceção.
      handler.next(options.copyWith(
        path: message.path,
        data: message.data,
        method: message.method,
        queryParameters: message.queryParameters,
        headers: message.headers,
        baseUrl: message.baseUrl,
      ));
    } else if (message is RestClientResponse) {
      handler.resolve(DioAdapter.toResponse(message));
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final restResponse = DioAdapter.toClientResponse(response);
    final message = await interceptor.onResponse(restResponse);

    if (message is RestClientException) {
      handler.reject(DioAdapter.toDioException(message));
    } else if (message is RestClientResponse) {
      handler.next(DioAdapter.toResponse(message));
    }
  }
}
