import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/entities/perfil_entity.dart';

class PerfilModel extends PerfilEntity {
  const PerfilModel(
      {required super.id,
      required super.name,
      required super.email,
      super.bio});

  /// [map] é o objeto do usuário (`data` de `GET/PUT /me`).
  factory PerfilModel.fromMap(Map<String, dynamic> map) {
    try {
      return PerfilModel(
        id: (map['id'] as num).toInt(),
        name: map['name'] as String,
        email: map['email'] as String,
        bio: map['bio'] as String?,
      );
    } catch (e, stackTrace) {
      throw Exception(
          'Error parsing PerfilModel: $e\nStack trace: $stackTrace');
    }
  }
}
