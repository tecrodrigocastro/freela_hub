import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_status.dart';

class CandidaturaModel extends CandidaturaEntity {
  const CandidaturaModel({
    required super.id,
    required super.vagaId,
    required super.vagaTitulo,
    super.vagaEmpresa,
    super.mensagem,
    super.valorProposto,
    required super.status,
    super.createdAt,
  });

  /// Recebe o objeto da candidatura (o `data` das respostas de docs/API.md).
  factory CandidaturaModel.fromMap(Map<String, dynamic> map) {
    try {
      final vaga = map['vaga'] as Map<String, dynamic>;
      return CandidaturaModel(
        id: map['id'] as int,
        vagaId: vaga['id'] as int,
        vagaTitulo: vaga['titulo'] as String,
        vagaEmpresa: vaga['empresa'] as String?,
        mensagem: map['mensagem'] as String?,
        valorProposto: (map['valor_proposto'] as num?)?.toDouble(),
        status: CandidaturaStatus.fromApi(map['status'] as String),
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? ''),
      );
    } catch (e, stackTrace) {
      throw Exception('Error parsing CandidaturaModel: $e\nStack trace: $stackTrace');
    }
  }
}
