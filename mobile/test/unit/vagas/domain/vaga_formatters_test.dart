import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/utils/vaga_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support.dart';

void main() {
  group('valorLabel', () {
    test('faixa fixa', () => expect(vaga(1).valorLabel, 'R\$ 3.000 – R\$ 5.000'));

    test('por hora', () {
      expect(vaga(1, tipo: TipoPagamento.hora, min: 90, max: 130).valorLabel, 'R\$ 90 – R\$ 130 /hora');
    });

    test('valor único quando min == max', () => expect(vaga(1, min: 800, max: 800).valorLabel, 'R\$ 800'));

    test('só mínimo', () => expect(vaga(1, max: null).valorLabel, 'A partir de R\$ 3.000'));

    test('só máximo', () => expect(vaga(1, min: null).valorLabel, 'Até R\$ 5.000'));

    test('sem valores', () => expect(vaga(1, min: null, max: null).valorLabel, 'A combinar'));
  });

  group('prazoLabel', () {
    test('plural', () => expect(vaga(1).prazoLabel, '45 dias'));
    test('singular', () => expect(vaga(1, prazo: 1).prazoLabel, '1 dia'));
    test('sem prazo', () => expect(vaga(1, prazo: null).prazoLabel, ''));
  });

  group('detalhe', () {
    test('valorRange não leva o sufixo /hora; valorTitulo diz o tipo', () {
      final porHora = vaga(1, tipo: TipoPagamento.hora, min: 90, max: 130);

      expect(porHora.valorRange, 'R\$ 90 – R\$ 130');
      expect(porHora.valorLabel, 'R\$ 90 – R\$ 130 /hora');
      expect(porHora.valorTitulo, 'Valor (por hora)');
      expect(vaga(1).valorTitulo, 'Valor (fixo)');
    });

    test('"A combinar" não ganha /hora', () {
      expect(vaga(1, tipo: TipoPagamento.hora, min: null, max: null).valorLabel, 'A combinar');
    });

    test('totalCandidaturasLabel', () {
      expect(vagaDetail(total: 0).totalCandidaturasLabel, 'Nenhuma candidatura até agora');
      expect(vagaDetail(total: 1).totalCandidaturasLabel, '1 candidatura até agora');
      expect(vagaDetail(total: 7).totalCandidaturasLabel, '7 candidaturas até agora');
    });
  });
}
