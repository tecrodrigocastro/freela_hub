import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/datasources/candidaturas_remote_datasource.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/models/candidatura_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/repositories/candidaturas_repository_impl.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/enviar_candidatura_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_status.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/repositories/candidaturas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/enviar_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/validators/enviar_candidatura_params_validators.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidatura_form_bloc.dart';
import 'package:base_clean_arch_bloc/src/core/client_http/client_http.dart';
import 'package:base_clean_arch_bloc/src/core/errors/credentials_validation_exception.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/services/candidatura_sent_notifier.dart';
import 'package:base_clean_arch_bloc/src/core/utils/brl_currency_input_formatter.dart';
import 'package:base_clean_arch_bloc/src/core/utils/endpoints.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

class MockRestClient extends Mock implements IRestClient {}

class MockDatasource extends Mock implements CandidaturasRemoteDatasource {}

class MockRepository extends Mock implements ICandidaturasRepository {}

class MockEnviarUsecase extends Mock implements EnviarCandidaturaUsecase {}

RestClientResponse _response(int status, dynamic data) => RestClientResponse(data: data, statusCode: status, request: RestClientRequest(path: '/x'));

const _mensagem = 'Tenho 3 anos de Flutter e já fiz apps de saúde.';

Map<String, dynamic> _createdJson() => {
      'data': {
        'id': 7,
        'vaga': {'id': 12, 'titulo': 'App Flutter para clínica'},
        'mensagem': _mensagem,
        'valor_proposto': 4200,
        'status': 'enviada',
        'created_at': '2026-10-09T18:00:00Z',
      },
    };

const _candidatura = CandidaturaEntity(id: 7, vagaId: 12, vagaTitulo: 'App Flutter para clínica', status: CandidaturaStatus.enviada);

void main() {
  setUpAll(() {
    registerFallbackValue(EnviarCandidaturaParams.empty());
    registerFallbackValue(RestClientRequest(path: ''));
  });

  group('EnviarCandidaturaParams', () {
    test('toJson: id vai na URL, valor só quando informado, mensagem sem espaços nas pontas', () {
      expect(EnviarCandidaturaParams(vagaId: 12, mensagem: '  $_mensagem ').toJson(), {'mensagem': _mensagem});
      expect(EnviarCandidaturaParams(vagaId: 12, mensagem: _mensagem, valorProposto: 4200).toJson(), {'mensagem': _mensagem, 'valor_proposto': 4200.0});
    });
  });

  group('EnviarCandidaturaParamsValidators', () {
    Set<String> invalid({String mensagem = _mensagem, double? valor}) =>
        EnviarCandidaturaParamsValidators().validate(EnviarCandidaturaParams(vagaId: 1, mensagem: mensagem, valorProposto: valor)).exceptions.map((e) => e.key).toSet();

    test('válido, com e sem valor', () {
      expect(invalid(), isEmpty);
      expect(invalid(valor: 4200), isEmpty);
    });

    test('mensagem vazia, curta (9) e no limite (10)', () {
      expect(invalid(mensagem: ''), {'mensagem'});
      expect(invalid(mensagem: '123456789'), {'mensagem'});
      expect(invalid(mensagem: '1234567890'), isEmpty);
    });

    test('espaços não contam para o mínimo', () {
      expect(invalid(mensagem: '     curta     '), {'mensagem'});
    });

    test('mensagem acima de 1000', () {
      expect(invalid(mensagem: 'a' * 1000), isEmpty);
      expect(invalid(mensagem: 'a' * 1001), {'mensagem'});
    });

    test('valor zero é inválido; nulo é aceito', () {
      expect(invalid(valor: 0), {'valorProposto'});
      expect(invalid(valor: null), isEmpty);
    });
  });

  group('CandidaturaModel', () {
    test('parseia a resposta do POST', () {
      final model = CandidaturaModel.fromMap(_createdJson()['data'] as Map<String, dynamic>);

      expect(model.id, 7);
      expect(model.vagaId, 12);
      expect(model.valorProposto, 4200.0);
      expect(model.status, CandidaturaStatus.enviada);
      expect(model.createdAt, DateTime.utc(2026, 10, 9, 18));
    });

    test('valor_proposto nulo e status desconhecido', () {
      final map = Map<String, dynamic>.from(_createdJson()['data'] as Map)
        ..['valor_proposto'] = null
        ..['status'] = 'em_analise';

      final model = CandidaturaModel.fromMap(map);

      expect(model.valorProposto, isNull);
      expect(model.status, CandidaturaStatus.emAnalise);
    });
  });

  group('CandidaturasRemoteDatasource', () {
    test('POST /vagas/{id}/candidaturas com mensagem e valor', () async {
      final client = MockRestClient();
      when(() => client.post(any())).thenAnswer((_) async => _response(201, _createdJson()));

      await CandidaturasRemoteDatasource(restClient: client).enviar(EnviarCandidaturaParams(vagaId: 12, mensagem: _mensagem, valorProposto: 4200));

      final request = verify(() => client.post(captureAny())).captured.single as RestClientRequest;
      expect(request.path, Endpoints.candidatarVaga(12));
      expect(request.data, {'mensagem': _mensagem, 'valor_proposto': 4200.0});
    });
  });

  group('CandidaturasRepositoryImpl', () {
    late MockDatasource datasource;
    late CandidaturasRepositoryImpl repository;
    final params = EnviarCandidaturaParams(vagaId: 12, mensagem: _mensagem);

    setUp(() {
      datasource = MockDatasource();
      repository = CandidaturasRepositoryImpl(datasource: datasource);
    });

    test('201 devolve a candidatura', () async {
      when(() => datasource.enviar(any())).thenAnswer((_) async => _response(201, _createdJson()));

      expect((await repository.enviar(params)).getOrNull()!.id, 7);
    });

    test('422 com erro por campo', () async {
      when(() => datasource.enviar(any())).thenAnswer((_) async => _response(422, {
            'message': 'The mensagem field must be at least 10 characters.',
            'errors': {
              'mensagem': ['The mensagem field must be at least 10 characters.'],
            },
          }));

      final failure = (await repository.enviar(params)).exceptionOrNull()! as ValidationException;

      expect(failure.firstErrorFor('mensagem'), isNotNull);
    });

    test('422 "já se candidatou" vem em errors.vaga', () async {
      when(() => datasource.enviar(any())).thenAnswer((_) async => _response(422, {
            'message': 'Você já se candidatou a esta vaga.',
            'errors': {
              'vaga': ['Você já se candidatou a esta vaga.'],
            },
          }));

      final failure = (await repository.enviar(params)).exceptionOrNull()! as ValidationException;

      expect(failure.message, 'Você já se candidatou a esta vaga.');
      expect(failure.firstErrorFor('vaga'), failure.message);
    });

    test('404 vira NotFoundException com mensagem própria', () async {
      when(() => datasource.enviar(any())).thenAnswer((_) async => _response(404, {'message': 'No query results for model'}));

      final failure = (await repository.enviar(params)).exceptionOrNull()! as NotFoundException;

      expect(failure.message, 'Esta vaga não está mais disponível.');
    });

    test('403 mantém a mensagem e o status da API', () async {
      when(() => datasource.enviar(any())).thenAnswer((_) async => _response(403, {'message': 'Apenas freelancers.'}));

      final failure = (await repository.enviar(params)).exceptionOrNull()! as DefaultException;

      expect(failure.statusCode, 403);
    });

    test('sem resposta do servidor vira NetworkException', () async {
      when(() => datasource.enviar(any())).thenThrow(RestClientException(message: 'timeout', error: 'x'));

      expect((await repository.enviar(params)).exceptionOrNull(), isA<NetworkException>());
    });
  });

  group('EnviarCandidaturaUsecase', () {
    late MockRepository repository;
    late CandidaturaSentNotifier notifier;
    late EnviarCandidaturaUsecase usecase;
    final params = EnviarCandidaturaParams(vagaId: 12, mensagem: _mensagem);

    setUp(() {
      repository = MockRepository();
      notifier = CandidaturaSentNotifier();
      usecase = EnviarCandidaturaUsecase(candidaturasRepository: repository, sentNotifier: notifier);
    });

    test('avisa o id da vaga quando envia', () async {
      when(() => repository.enviar(any())).thenAnswer((_) async => const Success(_candidatura));
      final sent = expectLater(notifier.onSent, emits(12));

      await usecase.call(params);

      await sent;
    });

    test('não avisa quando falha', () async {
      when(() => repository.enviar(any())).thenAnswer((_) async => const Failure(NetworkException()));
      final events = <int>[];
      final sub = notifier.onSent.listen(events.add);

      await usecase.call(params);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events, isEmpty);
    });
  });

  group('CandidaturaFormBloc', () {
    late MockEnviarUsecase enviar;

    setUp(() => enviar = MockEnviarUsecase());

    blocTest<CandidaturaFormBloc, CandidaturaFormState>(
      'envia e emite sucesso',
      build: () => CandidaturaFormBloc(enviarCandidaturaUsecase: enviar),
      setUp: () => when(() => enviar.call(any())).thenAnswer((_) async => const Success(_candidatura)),
      act: (bloc) => bloc.add(CandidaturaSubmitted(params: EnviarCandidaturaParams(vagaId: 12, mensagem: _mensagem))),
      expect: () => [const CandidaturaFormSubmitting(), const CandidaturaFormSuccess(_candidatura)],
    );

    blocTest<CandidaturaFormBloc, CandidaturaFormState>(
      'mensagem inválida não chega à API',
      build: () => CandidaturaFormBloc(enviarCandidaturaUsecase: enviar),
      act: (bloc) => bloc.add(CandidaturaSubmitted(params: EnviarCandidaturaParams(vagaId: 12, mensagem: 'curta'))),
      expect: () => [const CandidaturaFormSubmitting(), isA<CandidaturaFormFailure>().having((s) => s.exception, 'exception', isA<CredentialsValidationException>())],
      verify: (_) => verifyNever(() => enviar.call(any())),
    );

    blocTest<CandidaturaFormBloc, CandidaturaFormState>(
      'falha da API vira CandidaturaFormFailure',
      build: () => CandidaturaFormBloc(enviarCandidaturaUsecase: enviar),
      setUp: () => when(() => enviar.call(any())).thenAnswer((_) async => const Failure(NetworkException())),
      act: (bloc) => bloc.add(CandidaturaSubmitted(params: EnviarCandidaturaParams(vagaId: 12, mensagem: _mensagem))),
      expect: () => [const CandidaturaFormSubmitting(), isA<CandidaturaFormFailure>().having((s) => s.exception, 'exception', isA<NetworkException>())],
    );

    blocTest<CandidaturaFormBloc, CandidaturaFormState>(
      'toques repetidos durante o envio viram um único POST',
      build: () => CandidaturaFormBloc(enviarCandidaturaUsecase: enviar),
      setUp: () => when(() => enviar.call(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return const Success(_candidatura);
      }),
      act: (bloc) {
        final params = EnviarCandidaturaParams(vagaId: 12, mensagem: _mensagem);
        bloc
          ..add(CandidaturaSubmitted(params: params))
          ..add(CandidaturaSubmitted(params: params));
      },
      wait: const Duration(milliseconds: 100),
      verify: (_) => verify(() => enviar.call(any())).called(1),
    );
  });

  group('BrlCurrencyInputFormatter', () {
    String format(String typed) => BrlCurrencyInputFormatter().formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: typed)).text;

    test('digitar centavos monta a máscara pt-BR', () {
      expect(format('4'), '0,04');
      expect(format('420'), '4,20');
      expect(format('420000'), '4.200,00');
      expect(format('123456789'), '1.234.567,89');
    });

    test('limpar o campo devolve vazio', () => expect(format(''), ''));

    test('parse', () {
      expect(BrlCurrencyInputFormatter.parse('4.200,00'), 4200.0);
      expect(BrlCurrencyInputFormatter.parse('0,05'), 0.05);
      expect(BrlCurrencyInputFormatter.parse(''), isNull);
    });
  });
}
