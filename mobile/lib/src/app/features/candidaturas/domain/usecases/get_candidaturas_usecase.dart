import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/get_candidaturas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidaturas_page_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/repositories/candidaturas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:result_dart/result_dart.dart';

class GetCandidaturasUsecase implements UseCase<CandidaturasPageEntity, GetCandidaturasParams> {
  final ICandidaturasRepository _candidaturasRepository;

  GetCandidaturasUsecase({required ICandidaturasRepository candidaturasRepository}) : _candidaturasRepository = candidaturasRepository;

  @override
  AsyncResult<CandidaturasPageEntity> call(GetCandidaturasParams params) => _candidaturasRepository.getCandidaturas(params);
}
