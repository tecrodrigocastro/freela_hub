import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:result_dart/result_dart.dart';

/// Indica se há token salvo (usado pela Splash para escolher Vagas ou Login).
class CheckSessionUsecase implements UseCase<bool, NoParams> {
  final SessionService _sessionService;

  CheckSessionUsecase({required SessionService sessionService})
      : _sessionService = sessionService;

  @override
  AsyncResult<bool> call(NoParams params) async =>
      Success(await _sessionService.hasSession());
}
