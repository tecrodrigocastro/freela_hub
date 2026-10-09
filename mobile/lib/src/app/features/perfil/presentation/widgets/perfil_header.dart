import 'package:base_clean_arch_bloc/src/app/features/perfil/presentation/utils/perfil_formatters.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Avatar com iniciais, nome e e-mail.
class PerfilHeader extends StatelessWidget {
  final String name;
  final String email;

  const PerfilHeader({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: AppColors.terra, shape: BoxShape.circle),
          child: Text(
            iniciaisDe(name),
            style: AppTextStyles.titleTab
                .copyWith(color: Colors.white, fontSize: 30),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: AppTextStyles.titleSection.copyWith(fontSize: 22),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.xs),
              Text(email,
                  style: AppTextStyles.body.copyWith(color: AppColors.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
