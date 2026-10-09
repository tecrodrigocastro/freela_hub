import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';

enum PrimaryButtonVariant { filled, destructive }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final PrimaryButtonVariant variant;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = PrimaryButtonVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    final onTap = isLoading ? null : onPressed;
    final child = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: Colors.white),
          )
        : Text(label);

    if (variant == PrimaryButtonVariant.destructive) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: const BorderSide(color: AppColors.danger, width: 1.5),
          backgroundColor: AppColors.card,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: AppColors.danger),
              )
            : Text(label),
      );
    }

    // Loading mantém a cor cheia (só o toque é bloqueado).
    return FilledButton(
      onPressed: onTap ?? (isLoading ? () {} : null),
      child: child,
    );
  }
}
