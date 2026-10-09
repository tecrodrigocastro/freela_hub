/// Corpo de `PUT /me`. A tela edita só a bio; a API aceita `name` e `bio`.
class UpdatePerfilParams {
  String bio;

  UpdatePerfilParams({required this.bio});

  Map<String, dynamic> toJson() => {'bio': bio.trim()};

  void setBio(String value) => bio = value;

  static UpdatePerfilParams empty() => UpdatePerfilParams(bio: '');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdatePerfilParams && other.bio == bio;
  }

  @override
  int get hashCode => bio.hashCode;

  @override
  String toString() => 'UpdatePerfilParams(bio: $bio)';
}
