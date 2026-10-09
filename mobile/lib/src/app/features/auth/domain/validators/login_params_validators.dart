import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/login_params.dart';
import 'package:lucid_validation/lucid_validation.dart';

/// No login só exigimos preenchimento: a regra de formato da senha vale no
/// cadastro, e quem decide se a credencial é válida é a API.
class LoginParamsValidators extends LucidValidator<LoginParams> {
  LoginParamsValidators() {
    ruleFor((params) => params.email, key: 'email') //
        .notEmpty(message: 'Informe seu e-mail')
        .validEmail(message: 'E-mail inválido');
    ruleFor((params) => params.password, key: 'password') //
        .notEmpty(message: 'Informe sua senha');
  }
}
