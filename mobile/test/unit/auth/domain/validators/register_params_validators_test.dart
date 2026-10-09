import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/register_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/validators/register_params_validators.dart';
import 'package:flutter_test/flutter_test.dart';

RegisterParams _params({
  String name = 'Ana Souza',
  String email = 'ana@email.com',
  String password = 'secret123',
  String confirmation = 'secret123',
}) =>
    RegisterParams(name: name, email: email, password: password, passwordConfirmation: confirmation);

Set<String> _invalidKeys(RegisterParams params) => RegisterParamsValidators().validate(params).exceptions.map((e) => e.key).toSet();

void main() {
  test('dados válidos passam', () {
    expect(_invalidKeys(_params()), isEmpty);
  });

  test('campos vazios acusam todos os campos', () {
    expect(
      _invalidKeys(RegisterParams.empty()),
      {'name', 'email', 'password', 'passwordConfirmation'},
    );
  });

  test('e-mail inválido', () {
    expect(_invalidKeys(_params(email: 'ana')), {'email'});
  });

  test('senha com menos de 8 caracteres', () {
    expect(_invalidKeys(_params(password: 'abc1234', confirmation: 'abc1234')), {'password'});
  });

  test('confirmação diferente da senha', () {
    final result = RegisterParamsValidators().validate(_params(confirmation: 'secret12'));

    expect(result.exceptions.map((e) => e.key), ['passwordConfirmation']);
    expect(result.exceptions.single.message, 'As senhas não conferem.');
  });

  test('toJson usa password_confirmation como na API', () {
    expect(_params().toJson(), {
      'name': 'Ana Souza',
      'email': 'ana@email.com',
      'password': 'secret123',
      'password_confirmation': 'secret123',
    });
  });
}
