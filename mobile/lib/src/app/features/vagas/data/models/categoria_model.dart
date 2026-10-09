import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/categoria_entity.dart';

class CategoriaModel extends CategoriaEntity {
  const CategoriaModel({required super.id, required super.nome});

  Map<String, dynamic> toMap() => {'id': id, 'nome': nome};

  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    try {
      return CategoriaModel(id: map['id'] as int, nome: map['nome'] as String);
    } catch (e, stackTrace) {
      throw Exception('Error parsing CategoriaModel: $e\nStack trace: $stackTrace');
    }
  }
}
