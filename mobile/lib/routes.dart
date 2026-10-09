import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/pages/login_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/pages/register_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/pages/splash_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/base/presentation/pages/base_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/pages/candidatura_form_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/pages/candidaturas_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/presentation/pages/perfil_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/pages/vaga_detail_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/pages/vagas_page.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_refresh_listenable.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navegador raiz: telas que cobrem a bottom navigation (detalhe da vaga,
/// candidatar-se) usam `parentNavigatorKey: rootNavigatorKey`.
final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(
    {required SessionService sessionService,
    String initialLocation = AppPaths.splash}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: SessionRefreshListenable(sessionService),
    redirect: (context, state) async {
      final path = state.uri.path;
      if (path == AppPaths.splash) return null; // a Splash decide o destino

      final hasSession = await sessionService.hasSession();
      if (!hasSession && !AppPaths.publicPaths.contains(path)) return AppPaths.login;
      if (hasSession && AppPaths.authPaths.contains(path)) return AppPaths.vagas;
      return null;
    },
    routes: [
      GoRoute(
          path: AppPaths.splash,
          builder: (context, state) => const SplashPage()),
      GoRoute(
          path: AppPaths.login, builder: (context, state) => const LoginPage()),
      GoRoute(
          path: AppPaths.cadastro,
          builder: (context, state) => const RegisterPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => BasePage(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppPaths.vagas,
              builder: (context, state) => const VagasPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  parentNavigatorKey:
                      rootNavigatorKey, // cobre a bottom navigation
                  redirect: (context, state) =>
                      int.tryParse(state.pathParameters['id'] ?? '') == null
                          ? AppPaths.vagas
                          : null,
                  builder: (context, state) => VagaDetailPage(
                      vagaId: int.parse(state.pathParameters['id']!)),
                  routes: [
                    GoRoute(
                      path: 'candidatar',
                      parentNavigatorKey: rootNavigatorKey,
                      // Sem os dados da vaga (link direto, app reaberto) volta para o detalhe, de onde se candidata.
                      redirect: (context, state) =>
                          state.extra is CandidaturaFormArgs
                              ? null
                              : AppPaths.vagaDetalhe(
                                  int.parse(state.pathParameters['id']!)),
                      builder: (context, state) => CandidaturaFormPage(
                          args: state.extra! as CandidaturaFormArgs),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppPaths.candidaturas,
                builder: (context, state) =>
                    const CandidaturasPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppPaths.perfil,
                builder: (context, state) => const PerfilPage()),
          ]),
        ],
      ),
    ],
  );
}
