import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/register_params.dart';
import 'package:lucid_validation/lucid_validation.dart';

class RegisterParamsValidators extends LucidValidator<RegisterParams> {
  RegisterParamsValidators() {
    ruleFor((params) => params.name, key: 'name') //
        .notEmpty(message: 'Informe seu nome')
        .minLength(2, message: 'O nome deve ter no mínimo 2 caracteres');
    ruleFor((params) => params.email, key: 'email') //
        .notEmpty(message: 'Informe seu e-mail')
        .validEmail(message: 'E-mail inválido');
    ruleFor((params) => params.password, key: 'password') //
        .notEmpty(message: 'Informe uma senha')
        .minLength(8, message: 'A senha deve ter no mínimo 8 caracteres');
    ruleFor((params) => params.passwordConfirmation,
            key: 'passwordConfirmation') //
        .notEmpty(message: 'Confirme sua senha')
        .equalTo((params) => params.password,
            message: 'As senhas não conferem.');
  }
}
