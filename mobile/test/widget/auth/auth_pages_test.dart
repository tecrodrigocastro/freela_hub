import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/login_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/register_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/entities/auth_response_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/entities/user_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/login_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/register_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/pages/login_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/pages/register_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/pages/splash_page.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockCheckSessionUsecase extends Mock implements CheckSessionUsecase {}

const _auth = AuthResponseEntity(user: UserEntity(id: '4', email: 'ana@email.com', name: 'Ana'), token: '1|abc');

void main() {
  late MockLoginUsecase login;
  late MockRegisterUsecase register;
  late MockCheckSessionUsecase check;

  setUpAll(() {
    registerFallbackValue(LoginParams.empty());
    registerFallbackValue(RegisterParams.empty());
    registerFallbackValue(NoParams());
  });

  setUp(() {
    login = MockLoginUsecase();
    register = MockRegisterUsecase();
    check = MockCheckSessionUsecase();
    injector.registerFactory(() => AuthBloc(loginUsecase: login, registerUsecase: register, checkSessionUsecase: check));
  });

  tearDown(() => injector.reset());

  Future<void> pump(WidgetTester tester, String initial) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/cadastro', builder: (_, __) => const RegisterPage()),
        GoRoute(path: '/vagas', builder: (_, __) => const Scaffold(body: Text('HOME'))),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
    await tester.pump();
  }

  Finder field(int index) => find.byType(TextField).at(index);

  group('SplashPage', () {
    testWidgets('sem token vai para o login', (tester) async {
      when(() => check.call(any())).thenAnswer((_) async => const Success(false));

      await pump(tester, '/splash');
      expect(find.text('FreelaHub'), findsOneWidget);
      expect(find.text('Quadro de vagas freelance'), findsOneWidget);

      await tester.pump(SplashPage.minDuration + const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Entrar'), findsWidgets);
      expect(find.text('HOME'), findsNothing);
    });

    testWidgets('com token vai para as vagas', (tester) async {
      when(() => check.call(any())).thenAnswer((_) async => const Success(true));

      await pump(tester, '/splash');
      await tester.pump(SplashPage.minDuration + const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });
  });

  group('LoginPage', () {
    testWidgets('mostra campos e links do design', (tester) async {
      await pump(tester, '/login');

      expect(find.text('Acesse as vagas e acompanhe suas candidaturas.'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.textContaining('Não tem conta?', findRichText: true), findsOneWidget);
    });

    testWidgets('campos vazios mostram erro e não chamam a API', (tester) async {
      await pump(tester, '/login');

      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pump();

      expect(find.text('Informe seu e-mail'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
      verifyNever(() => login.call(any()));
    });

    testWidgets('login válido vai para as vagas', (tester) async {
      when(() => login.call(any())).thenAnswer((_) async => const Success(_auth));
      await pump(tester, '/login');

      await tester.enterText(field(0), 'freela@freelahub.test');
      await tester.enterText(field(1), 'password');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('credenciais inválidas (422 em email) aparecem no campo', (tester) async {
      when(() => login.call(any())).thenAnswer(
        (_) async => const Failure(ValidationException(message: 'Credenciais inválidas.', fieldErrors: {'email': ['Credenciais inválidas.']})),
      );
      await pump(tester, '/login');

      await tester.enterText(field(0), 'freela@freelahub.test');
      await tester.enterText(field(1), 'errada');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Credenciais inválidas.'), findsOneWidget);
    });

    testWidgets('erro de rede oferece tentar novamente', (tester) async {
      var calls = 0;
      when(() => login.call(any())).thenAnswer((_) async {
        calls++;
        return calls == 1 ? const Failure(NetworkException()) : const Success(_auth);
      });
      await pump(tester, '/login');

      await tester.enterText(field(0), 'freela@freelahub.test');
      await tester.enterText(field(1), 'password');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('Tentar novamente'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('link "Criar conta" abre o cadastro', (tester) async {
      await pump(tester, '/login');

      await tester.tap(find.textContaining('Criar conta', findRichText: true));
      await tester.pumpAndSettle();

      expect(find.text('Cadastre-se como freelancer e comece a se candidatar.'), findsOneWidget);
    });
  });

  group('RegisterPage', () {
    testWidgets('senhas diferentes mostram "As senhas não conferem."', (tester) async {
      await pump(tester, '/cadastro');

      await tester.enterText(field(0), 'Ana Souza');
      await tester.enterText(field(1), 'ana@email.com');
      await tester.enterText(field(2), 'secret123');
      await tester.enterText(field(3), 'secret12');
      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pump();

      expect(find.text('As senhas não conferem.'), findsOneWidget);
      verifyNever(() => register.call(any()));
    });

    testWidgets('cadastro válido vai para as vagas', (tester) async {
      when(() => register.call(any())).thenAnswer((_) async => const Success(_auth));
      await pump(tester, '/cadastro');

      await tester.enterText(field(0), 'Ana Souza');
      await tester.enterText(field(1), 'ana@email.com');
      await tester.enterText(field(2), 'secret123');
      await tester.enterText(field(3), 'secret123');
      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('422 da API (e-mail já usado) aparece no campo', (tester) async {
      when(() => register.call(any())).thenAnswer(
        (_) async => const Failure(ValidationException(message: 'E-mail já cadastrado.', fieldErrors: {'email': ['E-mail já cadastrado.']})),
      );
      await pump(tester, '/cadastro');

      await tester.enterText(field(0), 'Ana Souza');
      await tester.enterText(field(1), 'ana@email.com');
      await tester.enterText(field(2), 'secret123');
      await tester.enterText(field(3), 'secret123');
      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail já cadastrado.'), findsOneWidget);
    });

    testWidgets('link "Entrar" volta ao login', (tester) async {
      await pump(tester, '/cadastro');

      await tester.tap(find.textContaining('Já tem conta?', findRichText: true));
      await tester.pumpAndSettle();

      expect(find.text('Acesse as vagas e acompanhe suas candidaturas.'), findsOneWidget);
    });
  });
}
