import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/candidatura_id_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/repositories/candidaturas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:result_dart/result_dart.dart';

class GetCandidaturaUsecase implements UseCase<CandidaturaEntity, CandidaturaIdParams> {
  final ICandidaturasRepository _candidaturasRepository;

  GetCandidaturaUsecase({required ICandidaturasRepository candidaturasRepository}) : _candidaturasRepository = candidaturasRepository;

  @override
  AsyncResult<CandidaturaEntity> call(CandidaturaIdParams params) => _candidaturasRepository.getCandidatura(params);
}
