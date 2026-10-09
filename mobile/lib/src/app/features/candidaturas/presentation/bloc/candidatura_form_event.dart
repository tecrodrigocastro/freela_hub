part of 'candidatura_form_bloc.dart';

abstract class CandidaturaFormEvent extends Equatable {
  const CandidaturaFormEvent();

  @override
  List<Object> get props => [];
}

class CandidaturaSubmitted extends CandidaturaFormEvent {
  final EnviarCandidaturaParams params;

  const CandidaturaSubmitted({required this.params});

  @override
  List<Object> get props => [params];
}
