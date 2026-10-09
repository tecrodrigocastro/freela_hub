import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/enviar_candidatura_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_status.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/enviar_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidatura_form_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/pages/candidatura_form_page.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

class MockEnviarUsecase extends Mock implements EnviarCandidaturaUsecase {}

const _args = CandidaturaFormArgs(vagaId: 12, titulo: 'App Flutter para clínica', resumo: 'Clínica Vida · R\$ 3.000 – R\$ 5.000 · 45 dias');
const _mensagem = 'Tenho 3 anos de Flutter e já fiz apps de saúde.';
const _candidatura = CandidaturaEntity(id: 7, vagaId: 12, vagaTitulo: 'App Flutter para clínica', status: CandidaturaStatus.enviada);

void main() {
  late MockEnviarUsecase enviar;
  late GoRouter router;

  setUpAll(() => registerFallbackValue(EnviarCandidaturaParams.empty()));

  setUp(() {
    enviar = MockEnviarUsecase();
    injector.registerFactory(() => CandidaturaFormBloc(enviarCandidaturaUsecase: enviar));
  });

  tearDown(() async {
    router.dispose();
    await injector.reset();
  });

  /// Detalhe (`/vagas/12`) → formulário empilhado, como no app.
  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    router = GoRouter(
      initialLocation: '/vagas/12',
      routes: [
        GoRoute(
          path: '/vagas/12',
          builder: (context, _) => Scaffold(body: TextButton(onPressed: () => context.push('/vagas/12/candidatar', extra: _args), child: const Text('ABRIR'))),
          routes: [GoRoute(path: 'candidatar', builder: (_, state) => CandidaturaFormPage(args: state.extra! as CandidaturaFormArgs))],
        ),
        GoRoute(path: AppPaths.candidaturas, builder: (_, __) => const Scaffold(body: Text('ABA CANDIDATURAS'))),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
    await tester.tap(find.text('ABRIR'));
    await tester.pumpAndSettle();
  }

  final mensagem = find.byType(TextField).at(0);
  final valor = find.byType(TextField).at(1);
  final enviarButton = find.widgetWithText(FilledButton, 'Enviar candidatura');

  EnviarCandidaturaParams sentParams() => verify(() => enviar.call(captureAny())).captured.single as EnviarCandidaturaParams;

  testWidgets('mostra o resumo da vaga, os campos, o mínimo e o contador', (tester) async {
    await pump(tester);

    expect(find.text('Candidatar-se'), findsOneWidget);
    expect(find.text('App Flutter para clínica'), findsOneWidget);
    expect(find.text(_args.resumo), findsOneWidget);
    expect(find.text('Mensagem'), findsOneWidget);
    expect(find.text('Mínimo de 10 caracteres'), findsOneWidget);
    expect(find.text('0/1000'), findsOneWidget);
    expect(find.textContaining('(opcional)', findRichText: true), findsOneWidget);
    expect(enviarButton, findsOneWidget);

    await tester.enterText(mensagem, _mensagem);
    await tester.pump();
    expect(find.text('${_mensagem.length}/1000'), findsOneWidget);
  });

  testWidgets('mensagem vazia ou curta mostra o erro e não chama a API', (tester) async {
    await pump(tester);

    await tester.tap(enviarButton);
    await tester.pump();
    expect(find.text('Escreva uma mensagem para a empresa'), findsOneWidget);

    await tester.enterText(mensagem, 'curta');
    await tester.pump();
    expect(find.text('Escreva uma mensagem para a empresa'), findsNothing); // sumiu ao digitar

    await tester.tap(enviarButton);
    await tester.pump();
    expect(find.text('A mensagem precisa ter pelo menos 10 caracteres'), findsOneWidget);
    verifyNever(() => enviar.call(any()));
  });

  testWidgets('valor zero é recusado', (tester) async {
    await pump(tester);

    await tester.enterText(mensagem, _mensagem);
    await tester.enterText(valor, '0');
    await tester.tap(enviarButton);
    await tester.pump();

    expect(find.text('Informe um valor maior que zero'), findsOneWidget);
    verifyNever(() => enviar.call(any()));
  });

  testWidgets('máscara de reais e envio com valor: vai para a aba Candidaturas com snackbar', (tester) async {
    when(() => enviar.call(any())).thenAnswer((_) async => const Success(_candidatura));
    await pump(tester);

    await tester.enterText(mensagem, _mensagem);
    await tester.enterText(valor, '420000');
    await tester.pump();
    expect(find.text('4.200,00'), findsOneWidget);

    await tester.tap(enviarButton);
    await tester.pumpAndSettle();

    final params = sentParams();
    expect(params.vagaId, 12);
    expect(params.mensagem, _mensagem);
    expect(params.valorProposto, 4200.0);
    expect(find.text('ABA CANDIDATURAS'), findsOneWidget);
    expect(find.text('Candidatura enviada! Acompanhe o status por aqui.'), findsOneWidget);
  });

  testWidgets('valor é opcional: sem valor não envia valor_proposto', (tester) async {
    when(() => enviar.call(any())).thenAnswer((_) async => const Success(_candidatura));
    await pump(tester);

    await tester.enterText(mensagem, _mensagem);
    await tester.tap(enviarButton);
    await tester.pumpAndSettle();

    expect(sentParams().valorProposto, isNull);
  });

  testWidgets('botão fica em loading durante o envio', (tester) async {
    when(() => enviar.call(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(seconds: 1));
      return const Success(_candidatura);
    });
    await pump(tester);

    await tester.enterText(mensagem, _mensagem);
    await tester.tap(enviarButton);
    await tester.pump();

    expect(find.text('Enviar candidatura'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('422 em mensagem aparece no campo', (tester) async {
    when(() => enviar.call(any())).thenAnswer(
      (_) async => const Failure(ValidationException(message: 'Mensagem inválida.', fieldErrors: {'mensagem': ['Mensagem inválida.']})),
    );
    await pump(tester);

    await tester.enterText(mensagem, _mensagem);
    await tester.tap(enviarButton);
    await tester.pumpAndSettle();

    expect(find.text('Mensagem inválida.'), findsOneWidget);
    expect(find.text('ABA CANDIDATURAS'), findsNothing);
  });

  testWidgets('"já se candidatou" (errors.vaga) aparece como aviso do formulário', (tester) async {
    when(() => enviar.call(any())).thenAnswer(
      (_) async => const Failure(ValidationException(message: 'Você já se candidatou a esta vaga.', fieldErrors: {'vaga': ['Você já se candidatou a esta vaga.']})),
    );
    await pump(tester);

    await tester.enterText(mensagem, _mensagem);
    await tester.tap(enviarButton);
    await tester.pumpAndSettle();

    expect(find.text('Você já se candidatou a esta vaga.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsNothing);
  });

  testWidgets('erro de rede oferece tentar novamente e reenvia', (tester) async {
    var calls = 0;
    when(() => enviar.call(any())).thenAnswer((_) async => ++calls == 1 ? const Failure(NetworkException()) : const Success(_candidatura));
    await pump(tester);

    await tester.enterText(mensagem, _mensagem);
    await tester.tap(enviarButton);
    await tester.pumpAndSettle();
    expect(find.text('Tentar novamente'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('ABA CANDIDATURAS'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('X fecha e volta para o detalhe', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();

    expect(find.text('ABRIR'), findsOneWidget);
  });
}
