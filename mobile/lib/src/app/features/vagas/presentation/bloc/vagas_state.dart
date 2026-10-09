part of 'vagas_bloc.dart';

abstract class VagasState extends Equatable {
  final VagasFilterEntity filter;
  final List<CategoriaEntity> categorias;
  final bool categoriasFailed;

  const VagasState({
    this.filter = const VagasFilterEntity(),
    this.categorias = const [],
    this.categoriasFailed = false,
  });

  @override
  List<Object?> get props => [filter, categorias, categoriasFailed];
}

class VagasInitial extends VagasState {
  const VagasInitial();
}

class VagasLoading extends VagasState {
  const VagasLoading({super.filter, super.categorias, super.categoriasFailed});
}

class VagasLoaded extends VagasState {
  final List<VagaEntity> vagas;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final BaseException? loadMoreError;

  const VagasLoaded({
    required this.vagas,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
    super.filter,
    super.categorias,
    super.categoriasFailed,
  });

  VagasLoaded copyWith({
    List<VagaEntity>? vagas,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    BaseException? Function()? loadMoreError,
    List<CategoriaEntity>? categorias,
    bool? categoriasFailed,
  }) {
    return VagasLoaded(
      vagas: vagas ?? this.vagas,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError != null ? loadMoreError() : this.loadMoreError,
      filter: filter,
      categorias: categorias ?? this.categorias,
      categoriasFailed: categoriasFailed ?? this.categoriasFailed,
    );
  }

  @override
  List<Object?> get props => [...super.props, vagas, currentPage, hasMore, isLoadingMore, loadMoreError];
}

class VagasFailure extends VagasState {
  final BaseException exception;

  const VagasFailure({required this.exception, super.filter, super.categorias, super.categoriasFailed});

  @override
  List<Object?> get props => [...super.props, exception];
}
