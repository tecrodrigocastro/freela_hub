import 'package:base_clean_arch_bloc/src/app/features/candidaturas/data/models/candidatura_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidaturas_page_entity.dart';

class CandidaturasPageModel extends CandidaturasPageEntity {
  const CandidaturasPageModel({required super.candidaturas, required super.currentPage, required super.lastPage});

  factory CandidaturasPageModel.fromMap(Map<String, dynamic> map) {
    try {
      final meta = map['meta'] as Map<String, dynamic>;
      return CandidaturasPageModel(
        candidaturas: [for (final item in map['data'] as List) CandidaturaModel.fromMap(item as Map<String, dynamic>)],
        currentPage: meta['current_page'] as int,
        lastPage: meta['last_page'] as int,
      );
    } catch (e, stackTrace) {
      throw Exception('Error parsing CandidaturasPageModel: $e\nStack trace: $stackTrace');
    }
  }
}
