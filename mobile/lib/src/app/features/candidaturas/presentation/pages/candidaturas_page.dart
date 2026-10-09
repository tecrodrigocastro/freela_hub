import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/entities/candidatura_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidaturas_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/widgets/candidatura_card.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/widgets/candidatura_sheet.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CandidaturasPage extends StatelessWidget {
  const CandidaturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<CandidaturasBloc>()..add(const CandidaturasStarted()),
      child: const _CandidaturasView(),
    );
  }
}

class _CandidaturasView extends StatefulWidget {
  const _CandidaturasView();

  @override
  State<_CandidaturasView> createState() => _CandidaturasViewState();
}

class _CandidaturasViewState extends State<_CandidaturasView> {
  static const _loadMoreThreshold = 300.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  CandidaturasBloc get _bloc => context.read<CandidaturasBloc>();

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      _bloc.add(const CandidaturasNextPageRequested());
    }
  }

  Future<void> _refresh() async {
    _bloc.add(const CandidaturasRefreshed());
    await _bloc.stream.firstWhere((s) => s is CandidaturasLoaded || s is CandidaturasFailure);
  }

  Future<void> _openSheet(CandidaturaEntity candidatura) async {
    final result = await CandidaturaSheet.show(context, candidatura);
    if (result == CandidaturaSheetResult.retirar && mounted) await _confirmRetirar(candidatura);
  }

  Future<void> _confirmRetirar(CandidaturaEntity candidatura) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardShape),
        title: const Text('Retirar candidatura?', style: AppTextStyles.titleSection),
        content: Text(
          'Você deixa de concorrer a "${candidatura.vagaTitulo}". Essa ação não pode ser desfeita.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text('Retirar', style: AppTextStyles.weight(AppTextStyles.label.copyWith(color: AppColors.danger), FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) _bloc.add(CandidaturaRetirarRequested(candidatura.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocListener<CandidaturasBloc, CandidaturasState>(
          listenWhen: (a, b) => b is CandidaturasLoaded && b.feedback != null && (a is! CandidaturasLoaded || a.feedback != b.feedback),
          listener: (context, state) {
            final feedback = (state as CandidaturasLoaded).feedback!;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(feedback.message)));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.lg, AppSpacing.pageMargin, AppSpacing.md),
                child: Text('Candidaturas', style: AppTextStyles.titleTab),
              ),
              Expanded(child: BlocBuilder<CandidaturasBloc, CandidaturasState>(builder: _buildContent)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CandidaturasState state) {
    return switch (state) {
      CandidaturasInitial() || CandidaturasLoading() => const SkeletonList(),
      CandidaturasFailure() => _scrollable(
          ErrorState(
            message: state.exception is NetworkException ? state.exception.message : 'Algo deu errado. Tente novamente.',
            onRetry: () => _bloc.add(const CandidaturasRefreshed()),
          ),
        ),
      CandidaturasLoaded() when state.candidaturas.isEmpty => _scrollable(
          EmptyState(
            title: 'Você ainda não se candidatou',
            message: 'Encontre uma vaga e envie sua primeira candidatura.',
            actionLabel: 'Ver vagas',
            onAction: () => context.go(AppPaths.vagas),
          ),
        ),
      CandidaturasLoaded() => RefreshIndicator(
          color: AppColors.terra,
          onRefresh: _refresh,
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, 0, AppSpacing.pageMargin, AppSpacing.xl),
            itemCount: state.candidaturas.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index == state.candidaturas.length) return _Footer(state: state, onRetry: () => _bloc.add(const CandidaturasNextPageRequested()));

              final candidatura = state.candidaturas[index];
              return CandidaturaCard(
                candidatura: candidatura,
                isRemoving: state.removingIds.contains(candidatura.id),
                onTap: () => _openSheet(candidatura),
                onRetirar: () => _confirmRetirar(candidatura),
              );
            },
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  /// Estados vazio/erro precisam rolar para o pull-to-refresh funcionar.
  Widget _scrollable(Widget child) {
    return RefreshIndicator(
      color: AppColors.terra,
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(height: constraints.maxHeight, child: child),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final CandidaturasLoaded state;
  final VoidCallback onRetry;

  const _Footer({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.terra))),
      );
    }
    if (state.loadMoreError != null) {
      return Center(child: TextButton(onPressed: onRetry, child: const Text('Não foi possível carregar mais. Tentar novamente')));
    }
    return const SizedBox.shrink();
  }
}
