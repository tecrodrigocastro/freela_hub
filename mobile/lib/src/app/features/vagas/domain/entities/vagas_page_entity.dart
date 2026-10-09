import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_entity.dart';
import 'package:equatable/equatable.dart';

/// Uma página da listagem (`data` + `meta` de docs/API.md).
class VagasPageEntity extends Equatable {
  final List<VagaEntity> vagas;
  final int currentPage;
  final int lastPage;

  const VagasPageEntity({required this.vagas, required this.currentPage, required this.lastPage});

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [vagas, currentPage, lastPage];
}
