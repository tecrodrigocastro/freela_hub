import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PerfilSkeleton extends StatelessWidget {
  const PerfilSkeleton({super.key});

  Widget _block(double width, double height,
          {BoxShape shape = BoxShape.rectangle, double radius = 6}) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: shape,
          borderRadius:
              shape == BoxShape.circle ? null : BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cream2,
      highlightColor: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _block(72, 72, shape: BoxShape.circle),
              const SizedBox(width: AppSpacing.lg),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _block(160, 22),
                const SizedBox(height: AppSpacing.sm),
                _block(190, 16),
              ]),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _block(40, 14),
            const SizedBox(height: AppSpacing.sm),
            _block(double.infinity, 140, radius: AppRadius.card),
            const SizedBox(height: AppSpacing.sm),
            _block(double.infinity, 56, radius: AppRadius.button),
          ],
        ),
      ),
    );
  }
}
