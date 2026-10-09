import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_status.dart';
import 'package:equatable/equatable.dart';

class CandidaturaEntity extends Equatable {
  final int id;
  final int vagaId;
  final String vagaTitulo;
  final String? vagaEmpresa;
  final String? mensagem;
  final double? valorProposto;
  final CandidaturaStatus status;
  final DateTime? createdAt;

  const CandidaturaEntity({
    required this.id,
    required this.vagaId,
    required this.vagaTitulo,
    this.vagaEmpresa,
    this.mensagem,
    this.valorProposto,
    required this.status,
    this.createdAt,
  });

  @override
  String toString() => 'CandidaturaEntity(id: $id, vagaId: $vagaId, status: ${status.apiValue})';

  @override
  List<Object?> get props => [id, vagaId, vagaTitulo, vagaEmpresa, mensagem, valorProposto, status, createdAt];
}
