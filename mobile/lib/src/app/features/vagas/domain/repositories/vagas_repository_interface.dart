import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vaga_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vagas_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/categoria_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_detail_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vagas_page_entity.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class IVagasRepository {
  AsyncResult<VagasPageEntity> getVagas(GetVagasParams params);

  AsyncResult<VagaDetailEntity> getVaga(GetVagaParams params);

  AsyncResult<List<CategoriaEntity>> getCategorias();
}
