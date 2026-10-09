/// Rotas da API (contrato em docs/API.md).
///
/// A URL base vem de `--dart-define=API_URL=...`. O padrão aponta para o host
/// da máquina visto pelo emulador Android; no iOS use `http://localhost:8000/api`.
class Endpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.150.175.249:8000/api',
  );

  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String me = '$baseUrl/me';

  // Vagas
  static const String categorias = '$baseUrl/categorias';
  static const String vagas = '$baseUrl/vagas';
  static String vaga(int id) => '$vagas/$id';
  static String candidatarVaga(int id) => '$vagas/$id/candidaturas';

  // Candidaturas
  static const String candidaturas = '$baseUrl/candidaturas';
  static String candidatura(int id) => '$candidaturas/$id';
}
