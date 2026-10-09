import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/categoria_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vagas_filter_entity.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// Chips de filtro: Categoria (bottom sheet) e Modalidade (Todas/Remoto/Híbrido/Presencial).
class VagasFilterBar extends StatelessWidget {
  final VagasFilterEntity filter;
  final List<CategoriaEntity> categorias;
  final VoidCallback onCategoriaTap;
  final ValueChanged<Modalidade?> onModalidadeChanged;

  const VagasFilterBar({
    super.key,
    required this.filter,
    required this.categorias,
    required this.onCategoriaTap,
    required this.onModalidadeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categoria = categorias.where((c) => c.id == filter.categoriaId).firstOrNull;
    final hasCategoria = filter.categoriaId != null;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
        children: [
          _CategoriaChip(label: categoria?.nome ?? 'Categoria', selected: hasCategoria, onTap: onCategoriaTap),
          const SizedBox(width: AppSpacing.sm),
          FilterChipItem(label: 'Todas', selected: filter.modalidade == null, onTap: () => onModalidadeChanged(null)),
          for (final m in Modalidade.values) ...[
            const SizedBox(width: AppSpacing.sm),
            FilterChipItem(label: m.label, selected: filter.modalidade == m, onTap: () => onModalidadeChanged(m)),
          ],
        ],
      ),
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoriaChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.ink;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chipShape,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.terra : AppColors.card,
            borderRadius: AppRadius.chipShape,
            border: Border.all(color: selected ? AppColors.terra : AppColors.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.label.copyWith(color: color)),
              Icon(Icons.arrow_drop_down_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
