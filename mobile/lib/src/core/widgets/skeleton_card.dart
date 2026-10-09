import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Placeholder de carregamento com o mesmo formato do VagaCard.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  Widget _bar(double width, double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cream2,
      highlightColor: AppColors.card,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.cardShape,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(220, 18),
            const SizedBox(height: AppSpacing.sm),
            _bar(140, 14),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              _bar(80, 22),
              const SizedBox(width: AppSpacing.sm),
              _bar(64, 22)
            ]),
            const SizedBox(height: AppSpacing.md),
            _bar(160, 14),
          ],
        ),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int count;

  const SkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}
