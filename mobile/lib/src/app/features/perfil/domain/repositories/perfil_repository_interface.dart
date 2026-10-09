import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/dtos/update_perfil_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/entities/perfil_entity.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class IPerfilRepository {
  AsyncResult<PerfilEntity> getPerfil();

  AsyncResult<PerfilEntity> updatePerfil(UpdatePerfilParams params);

  /// Revoga o token no servidor (`POST /auth/logout`).
  AsyncResult<Unit> logout();
}
