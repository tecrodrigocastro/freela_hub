import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/dtos/update_perfil_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/entities/perfil_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/get_perfil_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/logout_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/usecases/update_perfil_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/validators/update_perfil_params_validators.dart';
import 'package:base_clean_arch_bloc/src/core/errors/credentials_validation_exception.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/extensions/lucid_validator_extensions.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:result_dart/result_dart.dart';

part 'perfil_event.dart';
part 'perfil_state.dart';

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  final GetPerfilUsecase _getPerfilUsecase;
  final UpdatePerfilUsecase _updatePerfilUsecase;
  final LogoutUsecase _logoutUsecase;

  PerfilBloc({
    required GetPerfilUsecase getPerfilUsecase,
    required UpdatePerfilUsecase updatePerfilUsecase,
    required LogoutUsecase logoutUsecase,
  })  : _getPerfilUsecase = getPerfilUsecase,
        _updatePerfilUsecase = updatePerfilUsecase,
        _logoutUsecase = logoutUsecase,
        super(const PerfilInitial()) {
    on<PerfilStarted>((event, emit) async {
      emit(const PerfilLoading());

      final result = await _getPerfilUsecase.call(NoParams());

      emit(result.fold(PerfilLoaded.new,
          (exception) => PerfilFailure(exception: exception as BaseException)));
    }, transformer: droppable());

    on<PerfilBioSaved>((event, emit) async {
      final current = state;
      if (current is! PerfilLoaded) return;
      final perfil = current.perfil;

      emit(PerfilSaving(perfil));

      final newState = await UpdatePerfilParamsValidators()
          .validateResult(UpdatePerfilParams(bio: event.bio))
          .flatMap(_updatePerfilUsecase.call)
          .fold(
              PerfilSaved.new,
              (exception) => PerfilSaveFailure(perfil,
                  exception: exception as BaseException));

      emit(newState);
    }, transformer: droppable());

    on<PerfilLogoutRequested>((event, emit) async {
      final current = state;
      if (current is! PerfilLoaded) return;

      emit(PerfilLoggingOut(current.perfil));

      await _logoutUsecase.call(NoParams());

      emit(const PerfilLoggedOut());
    }, transformer: droppable());
  }
}
