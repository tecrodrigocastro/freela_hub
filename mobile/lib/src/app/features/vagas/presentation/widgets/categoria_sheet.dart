import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/categoria_entity.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Resultado do bottom sheet: `null` fecha sem mudar; [CategoriaSheet.all] limpa o filtro.
class CategoriaSheet extends StatelessWidget {
  static const all = -1;

  final List<CategoriaEntity> categorias;
  final int? selectedId;
  final bool failed;
  final VoidCallback onRetry;

  const CategoriaSheet({super.key, required this.categorias, required this.selectedId, required this.failed, required this.onRetry});

  static Future<int?> show(
    BuildContext context, {
    required List<CategoriaEntity> categorias,
    required int? selectedId,
    required bool failed,
    required VoidCallback onRetry,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => CategoriaSheet(categorias: categorias, selectedId: selectedId, failed: failed, onRetry: onRetry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.formMargin, 0, AppSpacing.formMargin, AppSpacing.sm),
              child: Text('Categoria', style: AppTextStyles.titleSection),
            ),
            if (failed && categorias.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.formMargin),
                child: Row(
                  children: [
                    Expanded(child: Text('Não foi possível carregar as categorias.', style: AppTextStyles.body.copyWith(color: AppColors.muted))),
                    TextButton(
                      onPressed: () {
                        onRetry();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _Option(label: 'Todas as categorias', selected: selectedId == null, onTap: () => Navigator.of(context).pop(all)),
                    for (final c in categorias) _Option(label: c.nome, selected: c.id == selectedId, onTap: () => Navigator.of(context).pop(c.id)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Option({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: AppSpacing.minTouchTarget + 4,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.formMargin),
      title: Text(label, style: selected ? AppTextStyles.weight(AppTextStyles.body, FontWeight.w700) : AppTextStyles.body),
      trailing: selected ? const Icon(Icons.check_rounded, color: AppColors.terra) : null,
      onTap: onTap,
    );
  }
}
