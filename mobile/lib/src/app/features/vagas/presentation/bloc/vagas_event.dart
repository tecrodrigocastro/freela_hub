part of 'vagas_bloc.dart';

abstract class VagasEvent extends Equatable {
  const VagasEvent();

  @override
  List<Object> get props => [];
}

/// Primeira carga: categorias + página 1 sem filtros.
class VagasStarted extends VagasEvent {
  const VagasStarted();
}

/// Busca ou filtro mudou: recarrega a página 1 com o novo filtro.
class VagasFilterChanged extends VagasEvent {
  final VagasFilterEntity filter;

  const VagasFilterChanged(this.filter);

  @override
  List<Object> get props => [filter];
}

/// Pull-to-refresh ou "Tentar novamente": recarrega com o filtro atual.
class VagasRefreshed extends VagasEvent {
  const VagasRefreshed();
}

class VagasNextPageRequested extends VagasEvent {
  const VagasNextPageRequested();
}

class VagasCategoriasRequested extends VagasEvent {
  const VagasCategoriasRequested();
}

/// Uma candidatura foi enviada (por outra tela): marca a vaga como "Candidatado" na lista.
class VagasCandidaturaSent extends VagasEvent {
  final int vagaId;

  const VagasCandidaturaSent(this.vagaId);

  @override
  List<Object> get props => [vagaId];
}
