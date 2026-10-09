import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/entities/perfil_entity.dart';

const perfilAna = PerfilEntity(id: 4, name: 'Ana Souza', email: 'ana@email.com', bio: 'Dev Flutter com 3 anos de experiência.');

const perfilSemBio = PerfilEntity(id: 4, name: 'Ana Souza', email: 'ana@email.com');

/// Objeto `user` de `GET/PUT /me` (docs/API.md), dentro de `data`.
Map<String, dynamic> meJson({String? bio = 'Dev Flutter com 3 anos de experiência.'}) => {
      'data': {'id': 4, 'name': 'Ana Souza', 'email': 'ana@email.com', 'role': 'freelancer', 'bio': bio},
    };
