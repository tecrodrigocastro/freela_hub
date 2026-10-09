import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/repositories/perfil_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:base_clean_arch_bloc/src/core/services/session_service.dart';
import 'package:result_dart/result_dart.dart';

class LogoutUsecase implements UseCase<Unit, NoParams> {
  final IPerfilRepository _perfilRepository;
  final SessionService _sessionService;

  LogoutUsecase(
      {required IPerfilRepository perfilRepository,
      required SessionService sessionService})
      : _perfilRepository = perfilRepository,
        _sessionService = sessionService;

  /// Sempre encerra a sessão local, mesmo se a API falhar (sem rede, token já
  /// revogado): o usuário que toca em "Sair" não pode ficar preso. A revogação no
  /// servidor vem primeiro porque o interceptor ainda precisa do token.
  @override
  AsyncResult<Unit> call(NoParams params) async {
    await _perfilRepository.logout();
    await _sessionService.removeToken();

    return const Success(unit);
  }
}
