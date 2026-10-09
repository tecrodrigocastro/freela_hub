part of 'candidatura_detail_bloc.dart';

abstract class CandidaturaDetailEvent extends Equatable {
  const CandidaturaDetailEvent();

  @override
  List<Object> get props => [];
}

class CandidaturaDetailStarted extends CandidaturaDetailEvent {
  final int id;

  const CandidaturaDetailStarted(this.id);

  @override
  List<Object> get props => [id];
}
