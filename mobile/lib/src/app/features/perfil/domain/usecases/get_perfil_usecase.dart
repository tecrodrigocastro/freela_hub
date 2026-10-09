import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/entities/perfil_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/repositories/perfil_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:result_dart/result_dart.dart';

class GetPerfilUsecase implements UseCase<PerfilEntity, NoParams> {
  final IPerfilRepository _perfilRepository;

  GetPerfilUsecase({required IPerfilRepository perfilRepository})
      : _perfilRepository = perfilRepository;

  @override
  AsyncResult<PerfilEntity> call(NoParams params) =>
      _perfilRepository.getPerfil();
}
