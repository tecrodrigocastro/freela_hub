part of 'candidaturas_bloc.dart';

abstract class CandidaturasEvent extends Equatable {
  const CandidaturasEvent();

  @override
  List<Object> get props => [];
}

class CandidaturasStarted extends CandidaturasEvent {
  const CandidaturasStarted();
}

/// Pull-to-refresh, "Tentar novamente" ou candidatura nova enviada.
class CandidaturasRefreshed extends CandidaturasEvent {
  const CandidaturasRefreshed();
}

class CandidaturasNextPageRequested extends CandidaturasEvent {
  const CandidaturasNextPageRequested();
}

/// O usuário confirmou "Retirar candidatura".
class CandidaturaRetirarRequested extends CandidaturasEvent {
  final int id;

  const CandidaturaRetirarRequested(this.id);

  @override
  List<Object> get props => [id];
}
