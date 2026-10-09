part of 'candidatura_detail_bloc.dart';

abstract class CandidaturaDetailState extends Equatable {
  const CandidaturaDetailState();

  @override
  List<Object> get props => [];
}

class CandidaturaDetailInitial extends CandidaturaDetailState {
  const CandidaturaDetailInitial();
}

class CandidaturaDetailLoading extends CandidaturaDetailState {
  const CandidaturaDetailLoading();
}

class CandidaturaDetailLoaded extends CandidaturaDetailState {
  final CandidaturaEntity candidatura;

  const CandidaturaDetailLoaded(this.candidatura);

  @override
  List<Object> get props => [candidatura];
}

class CandidaturaDetailFailure extends CandidaturaDetailState {
  final BaseException exception;

  const CandidaturaDetailFailure({required this.exception});

  @override
  List<Object> get props => [exception];
}
