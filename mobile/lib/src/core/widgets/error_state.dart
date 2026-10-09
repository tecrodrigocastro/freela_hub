import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.message = 'Algo deu errado. Tente novamente.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Não foi possível carregar',
                style: AppTextStyles.titleSection),
            const SizedBox(height: AppSpacing.sm),
            Text(message,
                style: AppTextStyles.body.copyWith(color: AppColors.muted)),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: 'Tentar novamente', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
