import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/pages/candidatura_form_page.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_detail_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vaga_detail_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/utils/vaga_formatters.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/widgets/vaga_detail_skeleton.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/widgets/vaga_info_card.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VagaDetailPage extends StatelessWidget {
  final int vagaId;

  const VagaDetailPage({super.key, required this.vagaId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<VagaDetailBloc>()..add(VagaDetailStarted(vagaId)),
      child: _VagaDetailView(vagaId: vagaId),
    );
  }
}

class _VagaDetailView extends StatelessWidget {
  final int vagaId;

  const _VagaDetailView({required this.vagaId});

  void _back(BuildContext context) => context.canPop() ? context.pop() : context.go(AppPaths.vagas);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => _back(context)),
            Expanded(
              child: BlocBuilder<VagaDetailBloc, VagaDetailState>(
                builder: (context, state) => switch (state) {
                  VagaDetailInitial() || VagaDetailLoading() => const VagaDetailSkeleton(),
                  VagaDetailFailure(isNotFound: true) => EmptyState(
                      title: 'Vaga indisponível',
                      message: state.exception.message,
                      actionLabel: 'Voltar para as vagas',
                      onAction: () => _back(context),
                    ),
                  VagaDetailFailure() => ErrorState(
                      message: state.exception is NetworkException ? state.exception.message : 'Algo deu errado. Tente novamente.',
                      onRetry: () => context.read<VagaDetailBloc>().add(VagaDetailStarted(vagaId)),
                    ),
                  VagaDetailLoaded() => _Content(vaga: state.vaga),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, AppSpacing.pageMargin, AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Voltar',
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left_rounded, size: 32, color: AppColors.ink),
          ),
          Text('Vaga', style: AppTextStyles.weight(AppTextStyles.body.copyWith(fontSize: 18), FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final VagaDetailEntity vaga;

  const _Content({required this.vaga});

  @override
  Widget build(BuildContext context) {
    final paragraphs = vaga.descricao.split(RegExp(r'\n\s*\n')).map((p) => p.trim()).where((p) => p.isNotEmpty);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.sm, AppSpacing.pageMargin, AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vaga.titulo, style: AppTextStyles.titleTab.copyWith(fontSize: 30)),
                const SizedBox(height: AppSpacing.sm),
                Text(vaga.empresa, style: AppTextStyles.body.copyWith(color: AppColors.muted, fontSize: 18)),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [CategoryChip(label: vaga.categoria.nome), CategoryChip(label: vaga.modalidade.label)],
                ),
                const SizedBox(height: AppSpacing.xl),
                VagaInfoCard(valorTitulo: vaga.valorTitulo, valor: vaga.valorRange, prazo: vaga.prazoLabel),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'SOBRE A VAGA',
                  style: AppTextStyles.weight(
                    AppTextStyles.label.copyWith(color: AppColors.terraText, fontSize: 15, letterSpacing: 1.5),
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final p in paragraphs) ...[
                  Text(p, style: AppTextStyles.body.copyWith(fontSize: 17, height: 1.55)),
                  const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(vaga.totalCandidaturasLabel, style: AppTextStyles.caption.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ),
        _ApplyBar(vaga: vaga),
      ],
    );
  }
}

class _ApplyBar extends StatelessWidget {
  final VagaDetailEntity vaga;

  const _ApplyBar({required this.vaga});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.md, AppSpacing.pageMargin, AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: vaga.jaCandidatou
          ? const PrimaryButton(label: 'Candidatura enviada') // desabilitado: sem onPressed
          : PrimaryButton(label: 'Candidatar-se', onPressed: () => context.push(
                AppPaths.candidatar(vaga.id),
                extra: CandidaturaFormArgs(vagaId: vaga.id, titulo: vaga.titulo, resumo: vaga.resumoLabel),
              )),
    );
  }
}
