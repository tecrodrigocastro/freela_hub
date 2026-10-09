import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/categoria_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/repositories/vagas_repository_interface.dart';
import 'package:base_clean_arch_bloc/src/core/interfaces/usecase_interface.dart';
import 'package:result_dart/result_dart.dart';

class GetCategoriasUsecase implements UseCase<List<CategoriaEntity>, NoParams> {
  final IVagasRepository _vagasRepository;

  GetCategoriasUsecase({required IVagasRepository vagasRepository}) : _vagasRepository = vagasRepository;

  @override
  AsyncResult<List<CategoriaEntity>> call(NoParams params) => _vagasRepository.getCategorias();
}
