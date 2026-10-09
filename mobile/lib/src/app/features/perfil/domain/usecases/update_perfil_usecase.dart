import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/dtos/update_perfil_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/entities/perfil_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/repositories/perfil_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:result_dart/result_dart.dart';

class UpdatePerfilUsecase implements UseCase<PerfilEntity, UpdatePerfilParams> {
  final IPerfilRepository _perfilRepository;

  UpdatePerfilUsecase({required IPerfilRepository perfilRepository})
      : _perfilRepository = perfilRepository;

  @override
  AsyncResult<PerfilEntity> call(UpdatePerfilParams params) =>
      _perfilRepository.updatePerfil(params);
}
