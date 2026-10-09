/// Caminhos das rotas (go_router).
abstract final class AppPaths {
  static const splash = '/splash';
  static const login = '/login';
  static const cadastro = '/cadastro';

  static const vagas = '/vagas';
  static String vagaDetalhe(int id) => '$vagas/$id';
  static String candidatar(int id) => '$vagas/$id/candidatar';
  static const candidaturas = '/candidaturas';
  static const perfil = '/perfil';

  /// Rotas que não exigem sessão.
  static const publicPaths = {splash, login, cadastro};

  /// Rotas de autenticação: com sessão ativa não fazem sentido.
  static const authPaths = {login, cadastro};
}
