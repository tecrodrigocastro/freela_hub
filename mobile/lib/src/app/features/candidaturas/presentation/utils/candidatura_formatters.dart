import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_status.dart';
import 'package:base_clean_arch_bloc/src/core/utils/brl_format.dart';
import 'package:base_clean_arch_bloc/src/core/utils/short_date_format.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';

extension CandidaturaFormatters on CandidaturaEntity {
  /// `R$ 4.200`; vazio quando não houve valor proposto.
  String get valorLabel => valorProposto == null ? '' : formatBrl(valorProposto!);

  /// `03 out 2026`; vazio sem data.
  String get dataLabel => createdAt == null ? '' : formatShortDate(createdAt!);

  StatusChipType get chipType => StatusChipType.fromApi(status.apiValue);

  /// Só candidaturas `enviada` podem ser retiradas (docs/API.md).
  bool get podeRetirar => status == CandidaturaStatus.enviada;
}
