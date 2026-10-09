import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/dtos/login_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/domain/validators/login_params_validators.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _params = LoginParams.empty();
  final _validator = LoginParamsValidators();
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

    context.read<AuthBloc>().add(AuthLoginRequested(params: _params));
  }

  void _clearError(String field) {
    if (_fieldErrors.containsKey(field)) {
      setState(() => _fieldErrors.remove(field));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccess) context.go(AppPaths.vagas);
      },
      builder: (context, state) {
        final failure = state is AuthLoginFailure ? state.exception : null;
        final serverEmailError = failure is ValidationException
            ? failure.firstErrorFor('email')
            : null;
        final generalError = switch (failure) {
          null || ValidationException() => null,
          _ => failure.message,
        };

        return AuthScaffold(
          header: const BrandMark(),
          title: 'Entrar',
          subtitle: 'Acesse as vagas e acompanhe suas candidaturas.',
          footerText: 'Não tem conta?',
          footerAction: 'Criar conta',
          onFooterTap: () => context.go(AppPaths.cadastro),
          children: [
            AppTextField(
              label: 'E-mail',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: _fieldErrors['email'] ?? serverEmailError,
              onChanged: (value) {
                _params.setEmail(value);
                _clearError('email');
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Senha',
              obscureText: true,
              textInputAction: TextInputAction.done,
              errorText: _fieldErrors['password'],
              onChanged: (value) {
                _params.setPassword(value);
                _clearError('password');
              },
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
                label: 'Entrar',
                isLoading: state is AuthLoading,
                onPressed: _submit),
          ],
        );
      },
    );
  }
}
