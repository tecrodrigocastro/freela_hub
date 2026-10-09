import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/category_chip.dart';
import 'package:flutter/material.dart';

/// Card de vaga da lista. Recebe dados primitivos já formatados para não
/// depender de nenhuma feature (a feature `vagas` mapeia a entidade).
class VagaCard extends StatelessWidget {
  final String titulo;
  final String empresa;
  final String categoria;
  final String modalidade;
  final String valor;
  final String prazo;
  final bool jaCandidatou;
  final VoidCallback? onTap;

  const VagaCard({
    super.key,
    required this.titulo,
    required this.empresa,
    required this.categoria,
    required this.modalidade,
    required this.valor,
    required this.prazo,
    this.jaCandidatou = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardShape,
        side: const BorderSide(color: AppColors.outline),
      ),
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
                  Expanded(child: Text(titulo, style: AppTextStyles.titleCard)),
                  if (jaCandidatou) ...[
                    const SizedBox(width: AppSpacing.sm),
                    const _AppliedBadge(),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(empresa,
                  style: AppTextStyles.caption.copyWith(fontSize: 14)),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  CategoryChip(label: categoria),
                  CategoryChip(label: modalidade)
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      valor,
                      style: AppTextStyles.weight(AppTextStyles.body.copyWith(fontSize: 17, height: 1.3), FontWeight.w700),
                    ),
                  ),
                  if (prazo.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(prazo, style: AppTextStyles.caption.copyWith(fontSize: 14)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppliedBadge extends StatelessWidget {
  const _AppliedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: AppRadius.chipShape,
      ),
      child: Text('Candidatado',
          style: AppTextStyles.chip.copyWith(color: AppColors.success)),
    );
  }
}
