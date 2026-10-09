import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/register_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/entities/auth_response_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:result_dart/result_dart.dart';

class RegisterUsecase implements UseCase<AuthResponseEntity, RegisterParams> {
  final IAuthRepository _authRepository;
  final SessionService _sessionService;

  RegisterUsecase(
      {required IAuthRepository authRepository,
      required SessionService sessionService})
      : _authRepository = authRepository,
        _sessionService = sessionService;

  @override
  AsyncResult<AuthResponseEntity> call(RegisterParams params) async {
    final result = await _authRepository.register(params);

    final response = result.getOrNull();
    if (response != null) {
      await _sessionService.saveSession(response.token);
    }

    return result;
  }
}
