part of 'perfil_bloc.dart';

abstract class PerfilEvent extends Equatable {
  const PerfilEvent();

  @override
  List<Object> get props => [];
}

/// Carrega (ou recarrega, no "Tentar novamente") o perfil.
class PerfilStarted extends PerfilEvent {
  const PerfilStarted();
}

/// Salva a bio digitada (`PUT /me`).
class PerfilBioSaved extends PerfilEvent {
  final String bio;

  const PerfilBioSaved(this.bio);

  @override
  List<Object> get props => [bio];
}

class PerfilLogoutRequested extends PerfilEvent {
  const PerfilLogoutRequested();
}
