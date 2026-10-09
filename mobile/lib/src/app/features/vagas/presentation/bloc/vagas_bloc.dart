import 'dart:async';

import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vagas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/categoria_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vagas_filter_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_categorias_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vagas_usecase.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/services/candidatura_sent_notifier.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'vagas_event.dart';
part 'vagas_state.dart';

class VagasBloc extends Bloc<VagasEvent, VagasState> {
  final GetVagasUsecase _getVagasUsecase;
  final GetCategoriasUsecase _getCategoriasUsecase;
  StreamSubscription<int>? _sentSubscription;

  VagasBloc({
    required GetVagasUsecase getVagasUsecase,
    required GetCategoriasUsecase getCategoriasUsecase,
    CandidaturaSentNotifier? sentNotifier,
  })  : _getVagasUsecase = getVagasUsecase,
        _getCategoriasUsecase = getCategoriasUsecase,
        super(const VagasInitial()) {
    // restartable: uma busca nova cancela a anterior, então resposta atrasada não sobrescreve a mais recente.
    on<VagasStarted>(_onStarted, transformer: restartable());
    on<VagasFilterChanged>((event, emit) => _loadFirstPage(emit, event.filter), transformer: restartable());
    on<VagasRefreshed>((event, emit) => _loadFirstPage(emit, state.filter, showLoading: false), transformer: restartable());
    on<VagasNextPageRequested>(_onNextPage, transformer: droppable());
    on<VagasCategoriasRequested>(_onCategorias, transformer: droppable());
    on<VagasCandidaturaSent>(_onCandidaturaSent);

    _sentSubscription = sentNotifier?.onSent.listen((vagaId) => add(VagasCandidaturaSent(vagaId)));
  }

  @override
  Future<void> close() {
    _sentSubscription?.cancel();
    return super.close();
  }

  void _onCandidaturaSent(VagasCandidaturaSent event, Emitter<VagasState> emit) {
    final current = state;
    if (current is! VagasLoaded) return;

    emit(current.copyWith(
      vagas: [for (final v in current.vagas) v.id == event.vagaId ? v.copyWith(jaCandidatou: true) : v],
    ));
  }

  Future<void> _onStarted(VagasStarted event, Emitter<VagasState> emit) async {
    emit(const VagasLoading());

    final categorias = await _getCategoriasUsecase.call(NoParams());
    final lista = categorias.getOrNull() ?? const <CategoriaEntity>[];
    await _loadFirstPage(emit, const VagasFilterEntity(), showLoading: false, categorias: lista, categoriasFailed: categorias.isError());
  }

  Future<void> _loadFirstPage(
    Emitter<VagasState> emit,
    VagasFilterEntity filter, {
    bool showLoading = true,
    List<CategoriaEntity>? categorias,
    bool? categoriasFailed,
  }) async {
    final lista = categorias ?? state.categorias;
    final failed = categoriasFailed ?? state.categoriasFailed;

    if (showLoading) emit(VagasLoading(filter: filter, categorias: lista, categoriasFailed: failed));

    final result = await _getVagasUsecase.call(GetVagasParams.fromFilter(filter));

    emit(result.fold(
      (page) => VagasLoaded(
        vagas: page.vagas,
        currentPage: page.currentPage,
        hasMore: page.hasMore,
        filter: filter,
        categorias: lista,
        categoriasFailed: failed,
      ),
      (exception) => VagasFailure(exception: exception as BaseException, filter: filter, categorias: lista, categoriasFailed: failed),
    ));
  }

  Future<void> _onNextPage(VagasNextPageRequested event, Emitter<VagasState> emit) async {
    final current = state;
    if (current is! VagasLoaded || !current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true, loadMoreError: () => null));

    final result = await _getVagasUsecase.call(GetVagasParams.fromFilter(current.filter, page: current.currentPage + 1));

    emit(result.fold(
      (page) {
        final known = current.vagas.map((v) => v.id).toSet();
        return current.copyWith(
          vagas: [...current.vagas, ...page.vagas.where((v) => !known.contains(v.id))],
          currentPage: page.currentPage,
          hasMore: page.hasMore,
          isLoadingMore: false,
        );
      },
      (exception) => current.copyWith(isLoadingMore: false, loadMoreError: () => exception as BaseException),
    ));
  }

  Future<void> _onCategorias(VagasCategoriasRequested event, Emitter<VagasState> emit) async {
    final result = await _getCategoriasUsecase.call(NoParams());
    final lista = result.getOrNull();
    final current = state;

    if (current is VagasLoaded) {
      emit(current.copyWith(categorias: lista ?? current.categorias, categoriasFailed: lista == null));
    }
  }
}
