import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/utils/candidatura_formatters.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CandidaturaCard extends StatelessWidget {
  final CandidaturaEntity candidatura;
  final bool isRemoving;
  final VoidCallback onTap;
  final VoidCallback onRetirar;

  const CandidaturaCard({
    super.key,
    required this.candidatura,
    required this.isRemoving,
    required this.onTap,
    required this.onRetirar,
  });

  @override
  Widget build(BuildContext context) {
    final valor = candidatura.valorLabel;

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardShape, side: const BorderSide(color: AppColors.outline)),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardShape,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(candidatura.vagaTitulo, style: AppTextStyles.titleCard.copyWith(fontSize: 19))),
                  const SizedBox(width: AppSpacing.sm),
                  StatusChip(type: candidatura.chipType),
                ],
              ),
              if (candidatura.vagaEmpresa != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(candidatura.vagaEmpresa!, style: AppTextStyles.caption.copyWith(fontSize: 15)),
              ],
              if (valor.isNotEmpty || candidatura.podeRetirar || candidatura.dataLabel.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(valor, style: AppTextStyles.weight(AppTextStyles.body.copyWith(fontSize: 18), FontWeight.w700)),
                    ),
                    if (candidatura.podeRetirar)
                      _RetirarLink(isRemoving: isRemoving, onTap: onRetirar)
                    else
                      Text(candidatura.dataLabel, style: AppTextStyles.caption.copyWith(fontSize: 14)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RetirarLink extends StatelessWidget {
  final bool isRemoving;
  final VoidCallback onTap;

  const _RetirarLink({required this.isRemoving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isRemoving) {
      return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.danger));
    }

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: AppColors.danger, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm)),
      child: Text('Retirar candidatura', style: AppTextStyles.weight(AppTextStyles.label.copyWith(fontSize: 15, color: AppColors.danger), FontWeight.w700)),
    );
  }
}
