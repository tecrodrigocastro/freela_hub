import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_entity.dart';

/// Vaga completa de `GET /vagas/{id}`: os campos da lista + descrição e total de candidaturas.
class VagaDetailEntity extends VagaEntity {
  final String descricao;
  final int totalCandidaturas;

  const VagaDetailEntity({
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
    required this.descricao,
    required this.totalCandidaturas,
  });

  @override
  List<Object?> get props => [...super.props, descricao, totalCandidaturas];
}
