import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/enviar_candidatura_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/enviar_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/validators/enviar_candidatura_params_validators.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/extensions/lucid_validator_extensions.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:result_dart/result_dart.dart';

part 'candidatura_form_event.dart';
part 'candidatura_form_state.dart';

class CandidaturaFormBloc extends Bloc<CandidaturaFormEvent, CandidaturaFormState> {
  final EnviarCandidaturaUsecase _enviarCandidaturaUsecase;

  CandidaturaFormBloc({required EnviarCandidaturaUsecase enviarCandidaturaUsecase})
      : _enviarCandidaturaUsecase = enviarCandidaturaUsecase,
        super(const CandidaturaFormInitial()) {
    // droppable: toque duplo em "Enviar" não manda a candidatura duas vezes.
    on<CandidaturaSubmitted>((event, emit) async {
      emit(const CandidaturaFormSubmitting());

      final newState = await EnviarCandidaturaParamsValidators()
          .validateResult(event.params) //
          .flatMap(_enviarCandidaturaUsecase.call)
          .fold(CandidaturaFormSuccess.new, (exception) => CandidaturaFormFailure(exception: exception as BaseException));

      emit(newState);
    }, transformer: droppable());
  }
}
