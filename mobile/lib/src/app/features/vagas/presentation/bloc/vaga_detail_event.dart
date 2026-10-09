part of 'vaga_detail_bloc.dart';

abstract class VagaDetailEvent extends Equatable {
  const VagaDetailEvent();

  @override
  List<Object> get props => [];
}

/// Carrega (ou recarrega, no "Tentar novamente") a vaga [id].
class VagaDetailStarted extends VagaDetailEvent {
  final int id;

  const VagaDetailStarted(this.id);

  @override
  List<Object> get props => [id];
}
