import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Erro geral de um formulário (credenciais, rede). Com [onRetry] mostra o botão
/// "Tentar novamente".
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorBanner({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message,
              style: AppTextStyles.label.copyWith(color: AppColors.danger)),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger, padding: EdgeInsets.zero),
              child: const Text('Tentar novamente'),
            ),
        ],
      ),
    );
  }
}
