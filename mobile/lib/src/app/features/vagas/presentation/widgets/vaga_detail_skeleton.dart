import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VagaDetailSkeleton extends StatelessWidget {
  const VagaDetailSkeleton({super.key});

  Widget _bar(double width, double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cream2,
      highlightColor: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(280, 28),
            const SizedBox(height: AppSpacing.md),
            _bar(140, 18),
            const SizedBox(height: AppSpacing.lg),
            Row(children: [_bar(150, 28), const SizedBox(width: AppSpacing.sm), _bar(80, 28)]),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              height: 76,
              decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.cardShape),
            ),
            const SizedBox(height: AppSpacing.xl),
            _bar(120, 14),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < 5; i++) ...[_bar(double.infinity, 14), const SizedBox(height: AppSpacing.sm)],
          ],
        ),
      ),
    );
  }
}
