import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/categoria_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:equatable/equatable.dart';

class VagaEntity extends Equatable {
  final int id;
  final String titulo;
  final String empresa;
  final CategoriaEntity categoria;
  final Modalidade modalidade;
  final TipoPagamento tipoPagamento;
  final double? valorMin;
  final double? valorMax;
  final int? prazoDias;
  final bool jaCandidatou;

  const VagaEntity({
    required this.id,
    required this.titulo,
    required this.empresa,
    required this.categoria,
    required this.modalidade,
    required this.tipoPagamento,
    this.valorMin,
    this.valorMax,
    this.prazoDias,
    this.jaCandidatou = false,
  });

  VagaEntity copyWith({bool? jaCandidatou}) {
    return VagaEntity(
      id: id,
      titulo: titulo,
      empresa: empresa,
      categoria: categoria,
      modalidade: modalidade,
      tipoPagamento: tipoPagamento,
      valorMin: valorMin,
      valorMax: valorMax,
      prazoDias: prazoDias,
      jaCandidatou: jaCandidatou ?? this.jaCandidatou,
    );
  }

  @override
  String toString() => 'VagaEntity(id: $id, titulo: $titulo, empresa: $empresa)';

  @override
  List<Object?> get props => [id, titulo, empresa, categoria, modalidade, tipoPagamento, valorMin, valorMax, prazoDias, jaCandidatou];
}
