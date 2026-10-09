import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Chip pequeno e informativo (categoria, modalidade).
class CategoryChip extends StatelessWidget {
  final String label;

  const CategoryChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
      decoration: BoxDecoration(
          color: AppColors.cream2, borderRadius: AppRadius.chipShape),
      child: Text(label, style: AppTextStyles.chip),
    );
  }
}

/// Chip de filtro selecionável (Modalidade, Categoria).
class FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterChipItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chipShape,
        child: Container(
          constraints:
              const BoxConstraints(minHeight: AppSpacing.minTouchTarget - 8),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.terra : AppColors.card,
            borderRadius: AppRadius.chipShape,
            border: Border.all(
                color: selected ? AppColors.terra : AppColors.outline),
          ),
          child: Text(
            label,
            style: AppTextStyles.label
                .copyWith(color: selected ? Colors.white : AppColors.ink),
          ),
        ),
      ),
    );
  }
}
