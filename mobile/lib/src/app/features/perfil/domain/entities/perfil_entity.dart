import 'package:equatable/equatable.dart';

/// Perfil do freelancer logado (`GET /me`). A bio é opcional.
class PerfilEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? bio;

  const PerfilEntity({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
  });

  @override
  String toString() =>
      'PerfilEntity(id: $id, name: $name, email: $email, bio: $bio)';

  @override
  List<Object?> get props => [id, name, email, bio];
}
