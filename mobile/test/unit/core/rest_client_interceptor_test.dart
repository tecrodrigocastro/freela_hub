import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/dio/rest_client_dio_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Responde sempre [status] com [body], sem rede.
class _FakeAdapter implements HttpClientAdapter {
  final int status;
  final Map<String, dynamic> body;
  RequestOptions? last;

  _FakeAdapter(this.status, this.body);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    last = options;
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

class _TokenInterceptor implements IClientInterceptor {
  @override
  FutureOr<RestClientHttpMessage> onRequest(RestClientRequest request) => request..headers?.addAll({'Authorization': 'Bearer 1|abc'});

  @override
  FutureOr<RestClientHttpMessage> onResponse(RestClientResponse response) => response;

  @override
  FutureOr<RestClientHttpMessage> onError(RestClientException error) => error;
}

void main() {
  Future<(RestClientResponse?, Object?, _FakeAdapter)> post(int status, Map<String, dynamic> body, {required bool withInterceptor}) async {
    final adapter = _FakeAdapter(status, body);
    final dio = DioFactory.dio()..httpClientAdapter = adapter;
    final client = RestClientDioImpl(dio: dio);
    if (withInterceptor) client.addInterceptors(_TokenInterceptor());

    try {
      final response = await client.post(RestClientRequest(path: 'http://api.test/x', data: {'a': 1}, queryParameters: {'page': 2}));
      return (response, null, adapter);
    } catch (e) {
      return (null, e, adapter);
    }
  }

  for (final withInterceptor in [false, true]) {
    group('com interceptor de request: $withInterceptor', () {
      test('422 chega como resposta (não lança) com o corpo de erros', () async {
        final (response, error, _) = await post(422, {'message': 'x', 'errors': {'email': ['inválido']}}, withInterceptor: withInterceptor);

        expect(error, isNull);
        expect(response!.statusCode, 422);
        expect((response.data as Map)['errors'], {'email': ['inválido']});
      });

      test('404 e 403 também chegam como resposta', () async {
        for (final status in [403, 404]) {
          final (response, error, _) = await post(status, {'message': 'm'}, withInterceptor: withInterceptor);

          expect(error, isNull, reason: '$status');
          expect(response!.statusCode, status);
        }
      });

      test('5xx continua lançando RestClientException', () async {
        final (_, error, _) = await post(500, {'message': 'boom'}, withInterceptor: withInterceptor);

        expect(error, isA<RestClientException>());
      });
    });
  }

  test('o interceptor altera a requisição (header) sem perder dados nem query', () async {
    final (_, _, adapter) = await post(200, {'ok': true}, withInterceptor: true);

    expect(adapter.last!.headers['Authorization'], 'Bearer 1|abc');
    expect(adapter.last!.data, {'a': 1});
    expect(adapter.last!.queryParameters, {'page': 2});
    expect(adapter.last!.headers['Accept'], 'application/json');
  });
}
