import 'package:base_clean_arch_bloc/src/app/features/vagas/data/models/vaga_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_detail_entity.dart';

class VagaDetailModel extends VagaDetailEntity {
  const VagaDetailModel({
    required super.id,
    required super.titulo,
    required super.empresa,
    required super.categoria,
    required super.modalidade,
    required super.tipoPagamento,
    super.valorMin,
    super.valorMax,
    super.prazoDias,
    super.jaCandidatou,
    required super.descricao,
    required super.totalCandidaturas,
  });

  /// Recebe o objeto da vaga (o `data` de `GET /vagas/{id}`).
  factory VagaDetailModel.fromMap(Map<String, dynamic> map) {
    try {
      final base = VagaModel.fromMap(map);
      return VagaDetailModel(
        id: base.id,
        titulo: base.titulo,
        empresa: base.empresa,
        categoria: base.categoria,
        modalidade: base.modalidade,
        tipoPagamento: base.tipoPagamento,
        valorMin: base.valorMin,
        valorMax: base.valorMax,
        prazoDias: base.prazoDias,
        jaCandidatou: base.jaCandidatou,
        descricao: map['descricao'] as String? ?? '',
        totalCandidaturas: map['total_candidaturas'] as int? ?? 0,
      );
    } catch (e, stackTrace) {
      throw Exception('Error parsing VagaDetailModel: $e\nStack trace: $stackTrace');
    }
  }
}
