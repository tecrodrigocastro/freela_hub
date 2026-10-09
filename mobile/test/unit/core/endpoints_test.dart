import 'package:base_clean_arch_bloc/src/core/utils/endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rotas seguem o contrato de docs/API.md', () {
    expect(Endpoints.login, '${Endpoints.baseUrl}/auth/login');
    expect(Endpoints.me, '${Endpoints.baseUrl}/me');
    expect(Endpoints.vaga(12), '${Endpoints.baseUrl}/vagas/12');
    expect(Endpoints.candidatarVaga(12),
        '${Endpoints.baseUrl}/vagas/12/candidaturas');
    expect(Endpoints.candidatura(7), '${Endpoints.baseUrl}/candidaturas/7');
  });
}
