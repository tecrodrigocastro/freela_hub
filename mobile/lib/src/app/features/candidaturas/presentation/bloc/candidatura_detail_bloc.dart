import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/candidatura_id_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/get_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'candidatura_detail_event.dart';
part 'candidatura_detail_state.dart';

/// Carrega a candidatura completa (com a mensagem enviada) para o bottom sheet.
class CandidaturaDetailBloc extends Bloc<CandidaturaDetailEvent, CandidaturaDetailState> {
  final GetCandidaturaUsecase _getCandidaturaUsecase;

  CandidaturaDetailBloc({required GetCandidaturaUsecase getCandidaturaUsecase})
      : _getCandidaturaUsecase = getCandidaturaUsecase,
        super(const CandidaturaDetailInitial()) {
    on<CandidaturaDetailStarted>((event, emit) async {
      emit(const CandidaturaDetailLoading());

      final result = await _getCandidaturaUsecase.call(CandidaturaIdParams(id: event.id));

      emit(result.fold(CandidaturaDetailLoaded.new, (exception) => CandidaturaDetailFailure(exception: exception as BaseException)));
    }, transformer: droppable());
  }
}
