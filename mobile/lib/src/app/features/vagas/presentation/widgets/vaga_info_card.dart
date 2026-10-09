import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Bloco "Valor | Prazo" do detalhe da vaga.
class VagaInfoCard extends StatelessWidget {
  final String valorTitulo;
  final String valor;
  final String prazo;

  const VagaInfoCard({super.key, required this.valorTitulo, required this.valor, required this.prazo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.cardShape,
        border: Border.all(color: AppColors.outline),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _Info(label: valorTitulo, value: valor, fontSize: 22)),
            if (prazo.isNotEmpty) ...[
              const VerticalDivider(width: AppSpacing.xl, color: AppColors.outline),
              _Info(label: 'Prazo', value: prazo, fontSize: 22),
            ],
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;
  final double fontSize;

  const _Info({required this.label, required this.value, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(color: AppColors.muted, fontSize: 15)),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.weight(AppTextStyles.body.copyWith(fontSize: fontSize, height: 1.2), FontWeight.w700)),
      ],
    );
  }
}
