import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:equatable/equatable.dart';

/// Filtros ativos na lista (imutável, para o estado da tela).
class VagasFilterEntity extends Equatable {
  final String query;
  final int? categoriaId;
  final Modalidade? modalidade;

  const VagasFilterEntity({this.query = '', this.categoriaId, this.modalidade});

  bool get isEmpty => query.isEmpty && categoriaId == null && modalidade == null;

  VagasFilterEntity copyWith({
    String? query,
    int? Function()? categoriaId,
    Modalidade? Function()? modalidade,
  }) {
    return VagasFilterEntity(
      query: query ?? this.query,
      categoriaId: categoriaId != null ? categoriaId() : this.categoriaId,
      modalidade: modalidade != null ? modalidade() : this.modalidade,
    );
  }

  @override
  List<Object?> get props => [query, categoriaId, modalidade];
}
