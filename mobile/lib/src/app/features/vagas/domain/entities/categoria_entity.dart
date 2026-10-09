import 'package:equatable/equatable.dart';

class CategoriaEntity extends Equatable {
  final int id;
  final String nome;

  const CategoriaEntity({required this.id, required this.nome});

  @override
  String toString() => 'CategoriaEntity(id: $id, nome: $nome)';

  @override
  List<Object?> get props => [id, nome];
}
