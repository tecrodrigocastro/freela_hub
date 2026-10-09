import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_detail_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_entity.dart';
import 'package:base_clean_arch_bloc/src/core/utils/brl_format.dart';

/// Textos da vaga prontos para a UI (valores em BRL, prazo em dias).
extension VagaFormatters on VagaEntity {
  /// `R$ 3.000 – R$ 5.000`, `A partir de R$ 500`, `Até R$ 900` ou `A combinar` (sem o sufixo `/hora`).
  String get valorRange {
    final min = valorMin;
    final max = valorMax;

    if (min == null && max == null) return 'A combinar';
    if (min == null) return 'Até ${formatBrl(max!)}';
    if (max == null) return 'A partir de ${formatBrl(min)}';
    if (min == max) return formatBrl(min);
    return '${formatBrl(min)} – ${formatBrl(max)}';
  }

  /// Faixa para a lista: `R$ 90 – R$ 130 /hora` quando o pagamento é por hora.
  String get valorLabel {
    final hasValue = valorMin != null || valorMax != null;
    return hasValue && tipoPagamento == TipoPagamento.hora ? '$valorRange /hora' : valorRange;
  }

  /// `Clínica Vida · R$ 3.000 – R$ 5.000 · 45 dias` (resumo da vaga na tela de candidatura).
  String get resumoLabel => [empresa, valorLabel, if (prazoLabel.isNotEmpty) prazoLabel].join(' · ');

  /// Rótulo do bloco de valor no detalhe.
  String get valorTitulo => tipoPagamento == TipoPagamento.hora ? 'Valor (por hora)' : 'Valor (fixo)';

  /// `45 dias` (ou `1 dia`); vazio quando a vaga não informa prazo.
  String get prazoLabel {
    final dias = prazoDias;
    if (dias == null) return '';
    return dias == 1 ? '1 dia' : '$dias dias';
  }
}

extension VagaDetailFormatters on VagaDetailEntity {
  /// `7 candidaturas até agora`, `1 candidatura até agora` ou `Nenhuma candidatura até agora`.
  String get totalCandidaturasLabel => switch (totalCandidaturas) {
        0 => 'Nenhuma candidatura até agora',
        1 => '1 candidatura até agora',
        final n => '$n candidaturas até agora',
      };
}
