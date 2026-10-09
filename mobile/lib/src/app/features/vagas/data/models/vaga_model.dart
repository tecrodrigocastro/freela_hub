import 'package:base_clean_arch_bloc/src/app/features/vagas/data/models/categoria_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_entity.dart';

class VagaModel extends VagaEntity {
  const VagaModel({
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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'empresa': empresa,
      'categoria': {'id': categoria.id, 'nome': categoria.nome},
      'modalidade': modalidade.apiValue,
      'tipo_pagamento': tipoPagamento.apiValue,
      'valor_min': valorMin,
      'valor_max': valorMax,
      'prazo_dias': prazoDias,
      'ja_candidatou': jaCandidatou,
    };
  }

  factory VagaModel.fromMap(Map<String, dynamic> map) {
    try {
      return VagaModel(
        id: map['id'] as int,
        titulo: map['titulo'] as String,
        empresa: map['empresa'] as String,
        categoria: CategoriaModel.fromMap(map['categoria'] as Map<String, dynamic>),
        modalidade: Modalidade.fromApi(map['modalidade'] as String),
        tipoPagamento: TipoPagamento.fromApi(map['tipo_pagamento'] as String),
        valorMin: (map['valor_min'] as num?)?.toDouble(),
        valorMax: (map['valor_max'] as num?)?.toDouble(),
        prazoDias: map['prazo_dias'] as int?,
        jaCandidatou: map['ja_candidatou'] as bool? ?? false,
      );
    } catch (e, stackTrace) {
      throw Exception('Error parsing VagaModel: $e\nStack trace: $stackTrace');
    }
  }
}
