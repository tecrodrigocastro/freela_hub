part of 'candidaturas_bloc.dart';

abstract class CandidaturasState extends Equatable {
  const CandidaturasState();

  @override
  List<Object?> get props => [];
}

class CandidaturasInitial extends CandidaturasState {
  const CandidaturasInitial();
}

class CandidaturasLoading extends CandidaturasState {
  const CandidaturasLoading();
}

/// Aviso pontual (snackbar) depois de retirar uma candidatura. [id] distingue avisos iguais seguidos.
class CandidaturasFeedback extends Equatable {
  final int id;
  final String message;
  final bool isError;

  const CandidaturasFeedback({required this.id, required this.message, this.isError = false});

  @override
  List<Object> get props => [id, message, isError];
}

class CandidaturasLoaded extends CandidaturasState {
  final List<CandidaturaEntity> candidaturas;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final BaseException? loadMoreError;
  final Set<int> removingIds;
  final CandidaturasFeedback? feedback;

  const CandidaturasLoaded({
    required this.candidaturas,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.removingIds = const {},
    this.feedback,
  });

  CandidaturasLoaded copyWith({
    List<CandidaturaEntity>? candidaturas,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    BaseException? Function()? loadMoreError,
    Set<int>? removingIds,
    CandidaturasFeedback? feedback,
  }) {
    return CandidaturasLoaded(
      candidaturas: candidaturas ?? this.candidaturas,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError != null ? loadMoreError() : this.loadMoreError,
      removingIds: removingIds ?? this.removingIds,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [candidaturas, currentPage, hasMore, isLoadingMore, loadMoreError, removingIds, feedback];
}

class CandidaturasFailure extends CandidaturasState {
  final BaseException exception;

  const CandidaturasFailure({required this.exception});

  @override
  List<Object?> get props => [exception];
}
