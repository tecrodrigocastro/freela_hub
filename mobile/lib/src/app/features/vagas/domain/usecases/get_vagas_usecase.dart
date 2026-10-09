import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vagas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vagas_page_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/repositories/vagas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:result_dart/result_dart.dart';

class GetVagasUsecase implements UseCase<VagasPageEntity, GetVagasParams> {
  final IVagasRepository _vagasRepository;

  GetVagasUsecase({required IVagasRepository vagasRepository}) : _vagasRepository = vagasRepository;

  @override
  AsyncResult<VagasPageEntity> call(GetVagasParams params) => _vagasRepository.getVagas(params);
}
