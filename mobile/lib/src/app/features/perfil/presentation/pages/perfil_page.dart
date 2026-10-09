import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/entities/perfil_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/domain/validators/update_perfil_params_validators.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/presentation/bloc/perfil_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/presentation/widgets/perfil_header.dart';
import 'package:base_clean_arch_bloc/src/app/features/perfil/presentation/widgets/perfil_skeleton.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<PerfilBloc>()..add(const PerfilStarted()),
      child: const _PerfilView(),
    );
  }
}

class _PerfilView extends StatelessWidget {
  const _PerfilView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PerfilBloc, PerfilState>(
      listener: (context, state) {
        if (state is PerfilLoggedOut) context.go(AppPaths.login);

        if (state is PerfilSaved) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Perfil atualizado.')));
        }
      },
      builder: (context, state) => Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
                child: Text('Perfil', style: AppTextStyles.titleTab),
              ),
              Expanded(
                child: switch (state) {
                  PerfilInitial() ||
                  PerfilLoading() ||
                  PerfilLoggedOut() =>
                    const PerfilSkeleton(),
                  PerfilFailure() => ErrorState(
                      message: state.exception is NetworkException
                          ? state.exception.message
                          : 'Algo deu errado. Tente novamente.',
                      onRetry: () =>
                          context.read<PerfilBloc>().add(const PerfilStarted()),
                    ),
                  PerfilLoaded() => _PerfilForm(state: state),
                  _ => const SizedBox.shrink(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerfilForm extends StatefulWidget {
  final PerfilLoaded state;

  const _PerfilForm({required this.state});

  @override
  State<_PerfilForm> createState() => _PerfilFormState();
}

class _PerfilFormState extends State<_PerfilForm> {
  late final TextEditingController _bio =
      TextEditingController(text: widget.state.perfil.bio ?? '');

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  void _save() => context.read<PerfilBloc>().add(PerfilBioSaved(_bio.text));

  void _logout() =>
      context.read<PerfilBloc>().add(const PerfilLogoutRequested());

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final PerfilEntity perfil = state.perfil;
    final saving = state is PerfilSaving;
    final failure = state is PerfilSaveFailure ? state : null;
    final bioError = failure?.bioError;
    final generalError =
        failure != null && bioError == null ? failure.exception.message : null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PerfilHeader(name: perfil.name, email: perfil.email),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Bio',
                  controller: _bio,
                  hint: 'Conte um pouco sobre você e sua experiência.',
                  minLines: 4,
                  maxLines: 8,
                  maxLength: UpdatePerfilParamsValidators.bioMaxLength,
                  showCounter: false,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  enabled: !saving,
                  errorText: bioError,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (generalError != null) ...[
                  ErrorBanner(
                      message: generalError,
                      onRetry: failure!.exception is NetworkException
                          ? _save
                          : null),
                  const SizedBox(height: AppSpacing.sm),
                ],
                PrimaryButton(
                    label: 'Salvar', isLoading: saving, onPressed: _save),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
          child: PrimaryButton(
            label: 'Sair',
            variant: PrimaryButtonVariant.destructive,
            isLoading: state is PerfilLoggingOut,
            onPressed: saving ? null : _logout,
          ),
        ),
      ],
    );
  }
}
