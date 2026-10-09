import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Marca do app: quadrado terra com o "F" em Libre Baskerville.
class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.terra,
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: Text(
        'F',
        style: AppTextStyles.titleScreen.copyWith(
          color: AppColors.cream,
          fontSize: size * 0.55,
          height: 1,
        ),
      ),
    );
  }
}
