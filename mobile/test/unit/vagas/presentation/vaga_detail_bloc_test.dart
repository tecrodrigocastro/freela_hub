import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/dtos/get_vaga_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/usecases/get_vaga_usecase.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vaga_detail_bloc.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../support.dart';

class MockGetVagaUsecase extends Mock implements GetVagaUsecase {}

void main() {
  late MockGetVagaUsecase getVaga;

  setUpAll(() => registerFallbackValue(GetVagaParams.empty()));

  setUp(() => getVaga = MockGetVagaUsecase());

  blocTest<VagaDetailBloc, VagaDetailState>(
    'carrega a vaga pelo id',
    build: () => VagaDetailBloc(getVagaUsecase: getVaga),
    setUp: () => when(() => getVaga.call(any())).thenAnswer((_) async => Success(vagaDetail())),
    act: (bloc) => bloc.add(const VagaDetailStarted(12)),
    expect: () => [const VagaDetailLoading(), VagaDetailLoaded(vagaDetail())],
    verify: (_) => expect(verify(() => getVaga.call(captureAny())).captured.single, GetVagaParams(id: 12)),
  );

  blocTest<VagaDetailBloc, VagaDetailState>(
    '404 emite falha marcada como "não encontrada"',
    build: () => VagaDetailBloc(getVagaUsecase: getVaga),
    setUp: () => when(() => getVaga.call(any())).thenAnswer((_) async => Failure(NotFoundException(message: 'Esta vaga não está mais disponível.'))),
    act: (bloc) => bloc.add(const VagaDetailStarted(99)),
    expect: () => [const VagaDetailLoading(), isA<VagaDetailFailure>().having((s) => s.isNotFound, 'isNotFound', isTrue)],
  );

  blocTest<VagaDetailBloc, VagaDetailState>(
    'erro de rede não é "não encontrada" e permite tentar de novo',
    build: () => VagaDetailBloc(getVagaUsecase: getVaga),
    setUp: () {
      var calls = 0;
      when(() => getVaga.call(any())).thenAnswer((_) async => ++calls == 1 ? const Failure(NetworkException()) : Success(vagaDetail()));
    },
    act: (bloc) async {
      bloc.add(const VagaDetailStarted(12));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const VagaDetailStarted(12));
    },
    expect: () => [
      const VagaDetailLoading(),
      isA<VagaDetailFailure>().having((s) => s.isNotFound, 'isNotFound', isFalse),
      const VagaDetailLoading(),
      VagaDetailLoaded(vagaDetail()),
    ],
  );
}
