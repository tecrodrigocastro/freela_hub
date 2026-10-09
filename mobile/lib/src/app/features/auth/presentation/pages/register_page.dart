import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/register_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/validators/register_params_validators.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<AuthBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _params = RegisterParams.empty();
  final _validator = RegisterParamsValidators();
  final Map<String, String> _fieldErrors = {};

  void _submit() {
    final result = _validator.validate(_params);
    setState(() {
      _fieldErrors.clear();
      // Vários erros por campo: fica a primeira mensagem (ex.: "Informe..." antes de "inválido").
      for (final e in result.exceptions) {
        _fieldErrors.putIfAbsent(e.key, () => e.message);
      }
    });
    if (_fieldErrors.isNotEmpty) return;

    context.read<AuthBloc>().add(AuthRegisterRequested(params: _params));
  }

  void _onChanged(String field, void Function(String) setter, String value) {
    setter(value);
    if (_fieldErrors.containsKey(field)) {
      setState(() => _fieldErrors.remove(field));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) context.go(AppPaths.vagas);
      },
      builder: (context, state) {
        final failure = state is AuthRegisterFailure ? state.exception : null;
        final server = failure is ValidationException ? failure : null;
        final generalError = switch (failure) {
          null || ValidationException() => null,
          _ => failure.message,
        };

        String? error(String field, [String? apiField]) =>
            _fieldErrors[field] ?? server?.firstErrorFor(apiField ?? field);

        return AuthScaffold(
          title: 'Criar conta',
          subtitle: 'Cadastre-se como freelancer e comece a se candidatar.',
          footerText: 'Já tem conta?',
          footerAction: 'Entrar',
          onFooterTap: () => context.go(AppPaths.login),
          children: [
            AppTextField(
              label: 'Nome',
              textInputAction: TextInputAction.next,
              errorText: error('name'),
              onChanged: (v) => _onChanged('name', _params.setName, v),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'E-mail',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: error('email'),
              onChanged: (v) => _onChanged('email', _params.setEmail, v),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Senha',
              obscureText: true,
              textInputAction: TextInputAction.next,
              errorText: error('password'),
              onChanged: (v) => _onChanged('password', _params.setPassword, v),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Confirmar senha',
              obscureText: true,
              textInputAction: TextInputAction.done,
              errorText: error('passwordConfirmation', 'password_confirmation'),
              onChanged: (v) => _onChanged(
                  'passwordConfirmation', _params.setPasswordConfirmation, v),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (generalError != null) ...[
              ErrorBanner(
                message: generalError,
                onRetry: failure is NetworkException ? _submit : null,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            PrimaryButton(
                label: 'Criar conta',
                isLoading: state is AuthLoading,
                onPressed: _submit),
          ],
        );
      },
    );
  }
}
