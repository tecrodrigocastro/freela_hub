import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/login_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/register_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/entities/auth_response_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/login_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/usecases/register_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/validators/login_params_validators.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/validators/register_params_validators.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/extensions/lucid_validator_extensions.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:result_dart/result_dart.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final CheckSessionUsecase _checkSessionUsecase;

  AuthBloc({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
    required CheckSessionUsecase checkSessionUsecase,
  })  : _loginUsecase = loginUsecase,
        _registerUsecase = registerUsecase,
        _checkSessionUsecase = checkSessionUsecase,
        super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());

      final validator = LoginParamsValidators();

      final newState = await validator
          .validateResult(event.params) //
          .flatMap(_loginUsecase.call)
          .fold(
              AuthLoginSuccess.new,
              (exception) =>
                  AuthLoginFailure(exception: exception as BaseException));

      emit(newState);
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());

      final validator = RegisterParamsValidators();

      final newState = await validator
          .validateResult(event.params) //
          .flatMap(_registerUsecase.call)
          .fold(
              AuthRegisterSuccess.new,
              (exception) =>
                  AuthRegisterFailure(exception: exception as BaseException));

      emit(newState);
    });

    on<AuthSessionChecked>((event, emit) async {
      final hasSession =
          await _checkSessionUsecase.call(NoParams()).getOrDefault(false);

      emit(hasSession ? AuthAuthenticated() : AuthUnauthenticated());
    });
  }
}
