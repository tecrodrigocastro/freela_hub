import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/dtos/update_perfil_params.dart';
import 'package:lucid_validation/lucid_validation.dart';

class UpdatePerfilParamsValidators extends LucidValidator<UpdatePerfilParams> {
  static const bioMaxLength = 1000;

  UpdatePerfilParamsValidators() {
    ruleFor((params) => params.bio, key: 'bio') //
        .maxLength(bioMaxLength,
            message: 'A bio deve ter no máximo $bioMaxLength caracteres');
  }
}
