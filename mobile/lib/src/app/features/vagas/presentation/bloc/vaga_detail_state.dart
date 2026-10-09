part of 'vaga_detail_bloc.dart';

abstract class VagaDetailState extends Equatable {
  const VagaDetailState();

  @override
  List<Object> get props => [];
}

class VagaDetailInitial extends VagaDetailState {
  const VagaDetailInitial();
}

class VagaDetailLoading extends VagaDetailState {
  const VagaDetailLoading();
}

class VagaDetailLoaded extends VagaDetailState {
  final VagaDetailEntity vaga;

  const VagaDetailLoaded(this.vaga);

  @override
  List<Object> get props => [vaga];
}

class VagaDetailFailure extends VagaDetailState {
  final BaseException exception;

  const VagaDetailFailure({required this.exception});

  /// Vaga encerrada/inexistente (404): a tela oferece só "voltar".
  bool get isNotFound => exception is NotFoundException;

  @override
  List<Object> get props => [exception];
}
