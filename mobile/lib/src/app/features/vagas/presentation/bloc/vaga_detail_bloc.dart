import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vaga_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_detail_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vaga_usecase.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'vaga_detail_event.dart';
part 'vaga_detail_state.dart';

class VagaDetailBloc extends Bloc<VagaDetailEvent, VagaDetailState> {
  final GetVagaUsecase _getVagaUsecase;

  VagaDetailBloc({required GetVagaUsecase getVagaUsecase})
      : _getVagaUsecase = getVagaUsecase,
        super(const VagaDetailInitial()) {
    on<VagaDetailStarted>((event, emit) async {
      emit(const VagaDetailLoading());

      final result = await _getVagaUsecase.call(GetVagaParams(id: event.id));

      emit(result.fold(VagaDetailLoaded.new, (exception) => VagaDetailFailure(exception: exception as BaseException)));
    }, transformer: droppable());
  }
}
