import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vaga_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_detail_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/repositories/vagas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:result_dart/result_dart.dart';

class GetVagaUsecase implements UseCase<VagaDetailEntity, GetVagaParams> {
  final IVagasRepository _vagasRepository;

  GetVagaUsecase({required IVagasRepository vagasRepository}) : _vagasRepository = vagasRepository;

  @override
  AsyncResult<VagaDetailEntity> call(GetVagaParams params) => _vagasRepository.getVaga(params);
}
