import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vagas_filter_entity.dart';

class GetVagasParams {
  String query;
  int? categoriaId;
  Modalidade? modalidade;
  int page;

  GetVagasParams({
    this.query = '',
    this.categoriaId,
    this.modalidade,
    this.page = 1,
  });

  factory GetVagasParams.fromFilter(VagasFilterEntity filter, {int page = 1}) {
    return GetVagasParams(
      query: filter.query,
      categoriaId: filter.categoriaId,
      modalidade: filter.modalidade,
      page: page,
    );
  }

  /// Query string de `GET /vagas`: só envia o que foi preenchido.
  Map<String, dynamic> toJson() {
    return {
      if (query.trim().isNotEmpty) 'q': query.trim(),
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (modalidade != null) 'modalidade': modalidade!.apiValue,
      'page': page,
    };
  }

  void setQuery(String value) {
    query = value;
  }

  void setCategoriaId(int? value) {
    categoriaId = value;
  }

  void setModalidade(Modalidade? value) {
    modalidade = value;
  }

  void setPage(int value) {
    page = value;
  }

  static GetVagasParams empty() {
    return GetVagasParams();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetVagasParams &&
        other.query == query &&
        other.categoriaId == categoriaId &&
        other.modalidade == modalidade &&
        other.page == page;
  }

  @override
  int get hashCode => query.hashCode ^ categoriaId.hashCode ^ modalidade.hashCode ^ page.hashCode;

  @override
  String toString() => 'GetVagasParams(query: $query, categoriaId: $categoriaId, modalidade: $modalidade, page: $page)';
}
