import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/enviar_candidatura_params.dart';
import 'package:lucid_validation/lucid_validation.dart';

/// Regras de docs/API.md: `mensagem` 10–1000 caracteres, `valor_proposto` opcional e > 0.
class EnviarCandidaturaParamsValidators extends LucidValidator<EnviarCandidaturaParams> {
  static const mensagemMin = 10;
  static const mensagemMax = 1000;

  EnviarCandidaturaParamsValidators() {
    ruleFor((params) => params.mensagem.trim(), key: 'mensagem') //
        .notEmpty(message: 'Escreva uma mensagem para a empresa')
        .minLength(mensagemMin, message: 'A mensagem precisa ter pelo menos $mensagemMin caracteres')
        .maxLength(mensagemMax, message: 'A mensagem pode ter no máximo $mensagemMax caracteres');
    ruleFor((params) => params.valorProposto ?? 1, key: 'valorProposto') //
        .greaterThan(0, message: 'Informe um valor maior que zero');
  }
}
