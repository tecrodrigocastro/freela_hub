part of 'perfil_bloc.dart';

abstract class PerfilState extends Equatable {
  const PerfilState();

  @override
  List<Object> get props => [];
}

class PerfilInitial extends PerfilState {
  const PerfilInitial();
}

class PerfilLoading extends PerfilState {
  const PerfilLoading();
}

/// Falha ao carregar o perfil (a tela mostra "Tentar novamente").
class PerfilFailure extends PerfilState {
  final BaseException exception;

  const PerfilFailure({required this.exception});

  @override
  List<Object> get props => [exception];
}

/// Perfil carregado. Os estados abaixo o estendem para a tela continuar
/// mostrando o formulário enquanto salva, depois de salvar ou ao sair.
class PerfilLoaded extends PerfilState {
  final PerfilEntity perfil;

  const PerfilLoaded(this.perfil);

  @override
  List<Object> get props => [perfil];
}

class PerfilSaving extends PerfilLoaded {
  const PerfilSaving(super.perfil);
}

/// Bio salva: a tela mostra o aviso uma única vez.
class PerfilSaved extends PerfilLoaded {
  const PerfilSaved(super.perfil);
}

class PerfilSaveFailure extends PerfilLoaded {
  final BaseException exception;

  const PerfilSaveFailure(super.perfil, {required this.exception});

  /// Erro da bio (422 da API ou validação local), mostrado no campo.
  String? get bioError => switch (exception) {
        ValidationException(:final fieldErrors, :final message) =>
          fieldErrors['bio']?.firstOrNull ?? message,
        CredentialsValidationException(:final message) => message,
        _ => null,
      };

  @override
  List<Object> get props => [perfil, exception];
}

class PerfilLoggingOut extends PerfilLoaded {
  const PerfilLoggingOut(super.perfil);
}

/// Sessão encerrada: a tela volta ao login.
class PerfilLoggedOut extends PerfilState {
  const PerfilLoggedOut();
}
