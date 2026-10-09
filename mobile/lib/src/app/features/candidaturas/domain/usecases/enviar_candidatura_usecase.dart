import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/enviar_candidatura_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/repositories/candidaturas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/services/candidatura_sent_notifier.dart';
import 'package:result_dart/result_dart.dart';

class EnviarCandidaturaUsecase implements UseCase<CandidaturaEntity, EnviarCandidaturaParams> {
  final ICandidaturasRepository _candidaturasRepository;
  final CandidaturaSentNotifier _sentNotifier;

  EnviarCandidaturaUsecase({
    required ICandidaturasRepository candidaturasRepository,
    required CandidaturaSentNotifier sentNotifier,
  })  : _candidaturasRepository = candidaturasRepository,
        _sentNotifier = sentNotifier;

  @override
  AsyncResult<CandidaturaEntity> call(EnviarCandidaturaParams params) async {
    final result = await _candidaturasRepository.enviar(params);

    if (result.isSuccess()) _sentNotifier.notify(params.vagaId);

    return result;
  }
}
