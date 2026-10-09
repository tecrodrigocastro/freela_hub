part of 'candidatura_form_bloc.dart';

abstract class CandidaturaFormState extends Equatable {
  const CandidaturaFormState();

  @override
  List<Object> get props => [];
}

class CandidaturaFormInitial extends CandidaturaFormState {
  const CandidaturaFormInitial();
}

class CandidaturaFormSubmitting extends CandidaturaFormState {
  const CandidaturaFormSubmitting();
}

class CandidaturaFormSuccess extends CandidaturaFormState {
  final CandidaturaEntity candidatura;

  const CandidaturaFormSuccess(this.candidatura);

  @override
  List<Object> get props => [candidatura];
}

class CandidaturaFormFailure extends CandidaturaFormState {
  final BaseException exception;

  const CandidaturaFormFailure({required this.exception});

  @override
  List<Object> get props => [exception];
}
