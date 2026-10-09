import 'dart:async';

import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/dtos/update_perfil_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/entities/perfil_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/get_perfil_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/logout_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/update_perfil_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/presentation/bloc/perfil_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/presentation/pages/perfil_page.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../unit/perfil/support.dart';

class MockGetPerfilUsecase extends Mock implements GetPerfilUsecase {}

class MockUpdatePerfilUsecase extends Mock implements UpdatePerfilUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

void main() {
  late MockGetPerfilUsecase getPerfil;
  late MockUpdatePerfilUsecase updatePerfil;
  late MockLogoutUsecase logout;
  late GoRouter router;

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(UpdatePerfilParams.empty());
  });

  setUp(() {
    getPerfil = MockGetPerfilUsecase();
    updatePerfil = MockUpdatePerfilUsecase();
    logout = MockLogoutUsecase();
    when(() => getPerfil.call(any())).thenAnswer((_) async => const Success(perfilAna));
    when(() => logout.call(any())).thenAnswer((_) async => const Success(unit));
    injector.registerFactory(() => PerfilBloc(getPerfilUsecase: getPerfil, updatePerfilUsecase: updatePerfil, logoutUsecase: logout));
  });

  tearDown(() async {
    router.dispose();
    await injector.reset();
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    router = GoRouter(
      initialLocation: AppPaths.perfil,
      routes: [
        GoRoute(path: AppPaths.perfil, builder: (_, __) => const PerfilPage()),
        GoRoute(path: AppPaths.login, builder: (_, __) => const Scaffold(body: Text('tela de login'))),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
    await tester.pumpAndSettle();
  }

  String location() => router.routerDelegate.currentConfiguration.last.matchedLocation;

  Finder bioField() => find.byType(TextField);

  testWidgets('mostra avatar com iniciais, nome, e-mail e a bio atual', (tester) async {
    await pump(tester);

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('AS'), findsOneWidget);
    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text('ana@email.com'), findsOneWidget);
    expect(find.text('Bio'), findsOneWidget);
    expect(tester.widget<TextField>(bioField()).controller!.text, 'Dev Flutter com 3 anos de experiência.');
    expect(find.widgetWithText(FilledButton, 'Salvar'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Sair'), findsOneWidget);
  });

  testWidgets('perfil sem bio abre o campo vazio', (tester) async {
    when(() => getPerfil.call(any())).thenAnswer((_) async => const Success(perfilSemBio));

    await pump(tester);

    expect(tester.widget<TextField>(bioField()).controller!.text, isEmpty);
  });

  testWidgets('Salvar envia a bio digitada e avisa que o perfil foi atualizado', (tester) async {
    const atualizado = PerfilEntity(id: 4, name: 'Ana Souza', email: 'ana@email.com', bio: 'Nova bio');
    when(() => updatePerfil.call(any())).thenAnswer((_) async => const Success(atualizado));
    await pump(tester);

    await tester.enterText(bioField(), 'Nova bio');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(verify(() => updatePerfil.call(captureAny())).captured.single, UpdatePerfilParams(bio: 'Nova bio'));
    expect(find.text('Perfil atualizado.'), findsOneWidget);
    expect(tester.widget<TextField>(bioField()).controller!.text, 'Nova bio');
  });

  testWidgets('enquanto salva o botão mostra loading e o campo fica desabilitado', (tester) async {
    final pending = Completer<Result<PerfilEntity>>();
    when(() => updatePerfil.call(any())).thenAnswer((_) => pending.future);
    await pump(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<TextField>(bioField()).enabled, isFalse);

    pending.complete(const Success(perfilAna));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.widget<TextField>(bioField()).enabled, isTrue);
  });

  testWidgets('erro 422 da API aparece no campo, sem perder o texto', (tester) async {
    when(() => updatePerfil.call(any())).thenAnswer((_) async => const Failure(ValidationException(
          message: 'A bio é grande demais.',
          fieldErrors: {
            'bio': ['A bio é grande demais.'],
          },
        )));
    await pump(tester);

    await tester.enterText(bioField(), 'texto digitado');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('A bio é grande demais.'), findsOneWidget);
    expect(tester.widget<TextField>(bioField()).controller!.text, 'texto digitado');
  });

  testWidgets('sem rede ao salvar mostra o aviso com "Tentar novamente"', (tester) async {
    var calls = 0;
    when(() => updatePerfil.call(any())).thenAnswer((_) async => ++calls == 1 ? const Failure(NetworkException()) : const Success(perfilAna));
    await pump(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sem conexão'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.textContaining('Sem conexão'), findsNothing);
  });

  testWidgets('falha ao carregar mostra erro com retry', (tester) async {
    var calls = 0;
    when(() => getPerfil.call(any())).thenAnswer((_) async => ++calls == 1 ? const Failure(NetworkException()) : const Success(perfilAna));
    await pump(tester);

    expect(find.text('Não foi possível carregar'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Salvar'), findsNothing);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Souza'), findsOneWidget);
  });

  testWidgets('Sair encerra a sessão e volta ao login', (tester) async {
    await pump(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Sair'));
    await tester.pumpAndSettle();

    verify(() => logout.call(any())).called(1);
    expect(location(), AppPaths.login);
    expect(find.text('tela de login'), findsOneWidget);
  });
}
