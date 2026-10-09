import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Status de candidatura (docs/API.md): enviada · em_analise · aprovada · recusada.
enum StatusChipType {
  enviada('Enviada', AppColors.cream2, AppColors.ink),
  emAnalise('Em análise', AppColors.goldSoft, AppColors.ink),
  aprovada('Aprovada', AppColors.successSoft, AppColors.success),
  recusada('Recusada', AppColors.dangerSoft, AppColors.danger);

  final String label;
  final Color background;
  final Color foreground;

  const StatusChipType(this.label, this.background, this.foreground);

  static StatusChipType fromApi(String value) => switch (value) {
        'em_analise' => emAnalise,
        'aprovada' => aprovada,
        'recusada' => recusada,
        _ => enviada,
      };
}

class StatusChip extends StatelessWidget {
  final StatusChipType type;

  const StatusChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
          color: type.background, borderRadius: AppRadius.chipShape),
      child: Text(type.label,
          style: AppTextStyles.chip.copyWith(color: type.foreground)),
    );
  }
}
