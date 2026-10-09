import 'package:base_clean_arch_bloc/src/app/features/vagas/data/models/vaga_model.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vagas_page_entity.dart';

class VagasPageModel extends VagasPageEntity {
  const VagasPageModel({required super.vagas, required super.currentPage, required super.lastPage});

  factory VagasPageModel.fromMap(Map<String, dynamic> map) {
    try {
      final meta = map['meta'] as Map<String, dynamic>;
      return VagasPageModel(
        vagas: [for (final item in map['data'] as List) VagaModel.fromMap(item as Map<String, dynamic>)],
        currentPage: meta['current_page'] as int,
        lastPage: meta['last_page'] as int,
      );
    } catch (e, stackTrace) {
      throw Exception('Error parsing VagasPageModel: $e\nStack trace: $stackTrace');
    }
  }
}
