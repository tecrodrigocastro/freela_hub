import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidatura_detail_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/utils/candidatura_formatters.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

/// Resultado do sheet: o usuário pediu para retirar (a confirmação e a chamada ficam na lista).
enum CandidaturaSheetResult { retirar }

class CandidaturaSheet extends StatelessWidget {
  final CandidaturaEntity candidatura;

  const CandidaturaSheet({super.key, required this.candidatura});

  static Future<CandidaturaSheetResult?> show(BuildContext context, CandidaturaEntity candidatura) {
    return showModalBottomSheet<CandidaturaSheetResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => CandidaturaSheet(candidatura: candidatura),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<CandidaturaDetailBloc>()..add(CandidaturaDetailStarted(candidatura.id)),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.formMargin, 0, AppSpacing.formMargin, AppSpacing.lg),
            child: _SheetContent(candidatura: candidatura),
          ),
        ),
      ),
    );
  }
}

class _SheetContent extends StatelessWidget {
  final CandidaturaEntity candidatura;

  const _SheetContent({required this.candidatura});

  @override
  Widget build(BuildContext context) {
    final valor = candidatura.valorLabel;
    final data = candidatura.dataLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(candidatura.vagaTitulo, style: AppTextStyles.titleSection)),
            const SizedBox(width: AppSpacing.sm),
            StatusChip(type: candidatura.chipType),
          ],
        ),
        if (candidatura.vagaEmpresa != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(candidatura.vagaEmpresa!, style: AppTextStyles.body.copyWith(color: AppColors.muted)),
        ],
        if (valor.isNotEmpty || data.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: valor.isEmpty
                    ? const SizedBox.shrink()
                    : Text.rich(
                        TextSpan(
                          text: 'Valor proposto  ',
                          style: AppTextStyles.caption.copyWith(fontSize: 14),
                          children: [
                            TextSpan(
                              text: valor,
                              style: AppTextStyles.weight(AppTextStyles.body.copyWith(fontSize: 17), FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(data, style: AppTextStyles.caption.copyWith(fontSize: 14)),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          'MENSAGEM ENVIADA',
          style: AppTextStyles.weight(AppTextStyles.label.copyWith(color: AppColors.terraText, fontSize: 13, letterSpacing: 1.4), FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        BlocBuilder<CandidaturaDetailBloc, CandidaturaDetailState>(
          builder: (context, state) => switch (state) {
            CandidaturaDetailLoaded() => Text(state.candidatura.mensagem ?? '', style: AppTextStyles.body.copyWith(fontSize: 16, height: 1.5)),
            CandidaturaDetailFailure() => _MensagemError(
                exception: state.exception,
                onRetry: () => context.read<CandidaturaDetailBloc>().add(CandidaturaDetailStarted(candidatura.id)),
              ),
            _ => const _MensagemSkeleton(),
          },
        ),
        if (candidatura.podeRetirar) ...[
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Retirar candidatura',
            variant: PrimaryButtonVariant.destructive,
            onPressed: () => Navigator.of(context).pop(CandidaturaSheetResult.retirar),
          ),
        ],
      ],
    );
  }
}

class _MensagemSkeleton extends StatelessWidget {
  const _MensagemSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width) => Container(
          width: width,
          height: 14,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
        );

    return Shimmer.fromColors(
      baseColor: AppColors.cream2,
      highlightColor: AppColors.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [bar(double.infinity), bar(double.infinity), bar(160)]),
    );
  }
}

class _MensagemError extends StatelessWidget {
  final BaseException exception;
  final VoidCallback onRetry;

  const _MensagemError({required this.exception, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exception is NetworkException ? exception.message : 'Não foi possível carregar a mensagem.',
          style: AppTextStyles.body.copyWith(color: AppColors.muted),
        ),
        TextButton(onPressed: onRetry, style: TextButton.styleFrom(padding: EdgeInsets.zero), child: const Text('Tentar novamente')),
      ],
    );
  }
}
