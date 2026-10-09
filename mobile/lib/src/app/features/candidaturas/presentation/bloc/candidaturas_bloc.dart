import 'dart:async';

import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/candidatura_id_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/get_candidaturas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/get_candidaturas_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/usecases/retirar_candidatura_usecase.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/services/candidatura_sent_notifier.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'candidaturas_event.dart';
part 'candidaturas_state.dart';

class CandidaturasBloc extends Bloc<CandidaturasEvent, CandidaturasState> {
  final GetCandidaturasUsecase _getCandidaturasUsecase;
  final RetirarCandidaturaUsecase _retirarCandidaturaUsecase;
  StreamSubscription<int>? _sentSubscription;
  int _feedbackCount = 0;

  CandidaturasBloc({
    required GetCandidaturasUsecase getCandidaturasUsecase,
    required RetirarCandidaturaUsecase retirarCandidaturaUsecase,
    CandidaturaSentNotifier? sentNotifier,
  })  : _getCandidaturasUsecase = getCandidaturasUsecase,
        _retirarCandidaturaUsecase = retirarCandidaturaUsecase,
        super(const CandidaturasInitial()) {
    on<CandidaturasStarted>((event, emit) async {
      emit(const CandidaturasLoading());
      await _loadFirstPage(emit);
    }, transformer: restartable());
    on<CandidaturasRefreshed>((event, emit) => _loadFirstPage(emit), transformer: restartable());
    on<CandidaturasNextPageRequested>(_onNextPage, transformer: droppable());
    on<CandidaturaRetirarRequested>(_onRetirar, transformer: concurrent());

    // Candidatura nova (enviada em outra tela): a aba fica viva, então recarrega a lista.
    _sentSubscription = sentNotifier?.onSent.listen((_) => add(const CandidaturasRefreshed()));
  }

  @override
  Future<void> close() {
    _sentSubscription?.cancel();
    return super.close();
  }

  Future<void> _loadFirstPage(Emitter<CandidaturasState> emit) async {
    final result = await _getCandidaturasUsecase.call(GetCandidaturasParams());

    emit(result.fold(
      (page) => CandidaturasLoaded(candidaturas: page.candidaturas, currentPage: page.currentPage, hasMore: page.hasMore),
      (exception) => CandidaturasFailure(exception: exception as BaseException),
    ));
  }

  Future<void> _onNextPage(CandidaturasNextPageRequested event, Emitter<CandidaturasState> emit) async {
    final current = state;
    if (current is! CandidaturasLoaded || !current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true, loadMoreError: () => null));

    final result = await _getCandidaturasUsecase.call(GetCandidaturasParams(page: current.currentPage + 1));

    emit(result.fold(
      (page) {
        final known = current.candidaturas.map((c) => c.id).toSet();
        return current.copyWith(
          candidaturas: [...current.candidaturas, ...page.candidaturas.where((c) => !known.contains(c.id))],
          currentPage: page.currentPage,
          hasMore: page.hasMore,
          isLoadingMore: false,
        );
      },
      (exception) => current.copyWith(isLoadingMore: false, loadMoreError: () => exception as BaseException),
    ));
  }

  Future<void> _onRetirar(CandidaturaRetirarRequested event, Emitter<CandidaturasState> emit) async {
    final before = state;
    if (before is! CandidaturasLoaded || before.removingIds.contains(event.id)) return;

    emit(before.copyWith(removingIds: {...before.removingIds, event.id}));

    final result = await _retirarCandidaturaUsecase.call(CandidaturaIdParams(id: event.id));

    // Estado pode ter mudado durante a chamada (refresh, outra retirada): parte do atual.
    final current = state;
    if (current is! CandidaturasLoaded) return;
    final removing = {...current.removingIds}..remove(event.id);

    emit(result.fold(
      (_) => current.copyWith(
        candidaturas: current.candidaturas.where((c) => c.id != event.id).toList(),
        removingIds: removing,
        feedback: _feedback('Candidatura retirada.'),
      ),
      (exception) => current.copyWith(
        removingIds: removing,
        feedback: _feedback((exception as BaseException).message, isError: true),
      ),
    ));
  }

  CandidaturasFeedback _feedback(String message, {bool isError = false}) =>
      CandidaturasFeedback(id: ++_feedbackCount, message: message, isError: isError);
}
