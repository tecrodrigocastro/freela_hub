import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/candidatura_id_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/repositories/candidaturas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:result_dart/result_dart.dart';

class RetirarCandidaturaUsecase implements UseCase<Unit, CandidaturaIdParams> {
  final ICandidaturasRepository _candidaturasRepository;

  RetirarCandidaturaUsecase({required ICandidaturasRepository candidaturasRepository}) : _candidaturasRepository = candidaturasRepository;

  @override
  AsyncResult<Unit> call(CandidaturaIdParams params) => _candidaturasRepository.retirar(params);
}
