import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/candidatura_id_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/enviar_candidatura_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/get_candidaturas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidaturas_page_entity.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class ICandidaturasRepository {
  AsyncResult<CandidaturaEntity> enviar(EnviarCandidaturaParams params);

  AsyncResult<CandidaturasPageEntity> getCandidaturas(GetCandidaturasParams params);

  AsyncResult<CandidaturaEntity> getCandidatura(CandidaturaIdParams params);

  AsyncResult<Unit> retirar(CandidaturaIdParams params);
}
