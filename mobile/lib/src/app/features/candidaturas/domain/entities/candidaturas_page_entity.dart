import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:equatable/equatable.dart';

/// Uma página de `GET /candidaturas` (`data` + `meta`).
class CandidaturasPageEntity extends Equatable {
  final List<CandidaturaEntity> candidaturas;
  final int currentPage;
  final int lastPage;

  const CandidaturasPageEntity({required this.candidaturas, required this.currentPage, required this.lastPage});

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [candidaturas, currentPage, lastPage];
}
