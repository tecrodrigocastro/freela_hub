import 'dart:async';

import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vagas_filter_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/bloc/vagas_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/utils/vaga_formatters.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/widgets/categoria_sheet.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/widgets/vagas_filter_bar.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/presentation/widgets/vagas_search_field.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VagasPage extends StatelessWidget {
  const VagasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<VagasBloc>()..add(const VagasStarted()),
      child: const _VagasView(),
    );
  }
}

class _VagasView extends StatefulWidget {
  const _VagasView();

  @override
  State<_VagasView> createState() => _VagasViewState();
}

class _VagasViewState extends State<_VagasView> {
  static const _debounce = Duration(milliseconds: 400);
  static const _loadMoreThreshold = 300.0;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  VagasBloc get _bloc => context.read<VagasBloc>();

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      _bloc.add(const VagasNextPageRequested());
    }
  }

  void _search(String value, {bool immediately = false}) {
    _searchTimer?.cancel();
    void apply() => _bloc.add(VagasFilterChanged(_bloc.state.filter.copyWith(query: value.trim())));

    if (immediately) {
      apply();
    } else {
      _searchTimer = Timer(_debounce, apply);
    }
  }

  void _setModalidade(Modalidade? modalidade) {
    _bloc.add(VagasFilterChanged(_bloc.state.filter.copyWith(modalidade: () => modalidade)));
  }

  Future<void> _pickCategoria() async {
    final state = _bloc.state;
    final result = await CategoriaSheet.show(
      context,
      categorias: state.categorias,
      selectedId: state.filter.categoriaId,
      failed: state.categoriasFailed,
      onRetry: () => _bloc.add(const VagasCategoriasRequested()),
    );
    if (result == null) return;

    _bloc.add(VagasFilterChanged(state.filter.copyWith(categoriaId: () => result == CategoriaSheet.all ? null : result)));
  }

  void _clearFilters() {
    _searchTimer?.cancel();
    _searchController.clear();
    _bloc.add(const VagasFilterChanged(VagasFilterEntity()));
  }

  Future<void> _refresh() async {
    _bloc.add(const VagasRefreshed());
    await _bloc.stream.firstWhere((s) => s is VagasLoaded || s is VagasFailure);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.lg, AppSpacing.pageMargin, AppSpacing.md),
              child: Text('Vagas', style: AppTextStyles.titleTab),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
              child: VagasSearchField(
                controller: _searchController,
                onChanged: _search,
                onSubmitted: (value) => _search(value, immediately: true),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BlocBuilder<VagasBloc, VagasState>(
              buildWhen: (a, b) => a.filter != b.filter || a.categorias != b.categorias,
              builder: (context, state) => VagasFilterBar(
                filter: state.filter,
                categorias: state.categorias,
                onCategoriaTap: _pickCategoria,
                onModalidadeChanged: _setModalidade,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: BlocBuilder<VagasBloc, VagasState>(builder: _buildContent)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, VagasState state) {
    return switch (state) {
      VagasInitial() || VagasLoading() => const SkeletonList(),
      VagasFailure() => _scrollable(
          ErrorState(
            message: state.exception is NetworkException ? state.exception.message : 'Algo deu errado. Tente novamente.',
            onRetry: () => _bloc.add(const VagasRefreshed()),
          ),
        ),
      VagasLoaded() when state.vagas.isEmpty => _scrollable(
          EmptyState(
            title: 'Nenhuma vaga encontrada',
            message: state.filter.isEmpty ? 'Ainda não há vagas abertas. Volte em breve.' : 'Tente limpar os filtros.',
            actionLabel: state.filter.isEmpty ? null : 'Limpar filtros',
            onAction: _clearFilters,
          ),
        ),
      VagasLoaded() => RefreshIndicator(
          color: AppColors.terra,
          onRefresh: _refresh,
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, 0, AppSpacing.pageMargin, AppSpacing.xl),
            itemCount: state.vagas.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) =>
                index < state.vagas.length ? _card(state.vagas[index]) : _Footer(state: state, onRetry: () => _bloc.add(const VagasNextPageRequested())),
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _card(VagaEntity vaga) {
    return VagaCard(
      titulo: vaga.titulo,
      empresa: vaga.empresa,
      categoria: vaga.categoria.nome,
      modalidade: vaga.modalidade.label,
      valor: vaga.valorLabel,
      prazo: vaga.prazoLabel,
      jaCandidatou: vaga.jaCandidatou,
      onTap: () => context.push(AppPaths.vagaDetalhe(vaga.id)),
    );
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
  final VagasLoaded state;
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
