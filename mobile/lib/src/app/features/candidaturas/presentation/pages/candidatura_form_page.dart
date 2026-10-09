import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/dtos/enviar_candidatura_params.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/domain/validators/enviar_candidatura_params_validators.dart';
import 'package:base_clean_arch_bloc/src/app/features/candidaturas/presentation/bloc/candidatura_form_bloc.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/errors/errors.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:base_clean_arch_bloc/src/core/utils/brl_currency_input_formatter.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Dados da vaga que a tela mostra no resumo (vêm do detalhe, sem nova chamada à API).
class CandidaturaFormArgs {
  final int vagaId;
  final String titulo;
  final String resumo;

  const CandidaturaFormArgs({required this.vagaId, required this.titulo, required this.resumo});
}

class CandidaturaFormPage extends StatelessWidget {
  final CandidaturaFormArgs args;

  const CandidaturaFormPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<CandidaturaFormBloc>(),
      child: _CandidaturaFormView(args: args),
    );
  }
}

class _CandidaturaFormView extends StatefulWidget {
  final CandidaturaFormArgs args;

  const _CandidaturaFormView({required this.args});

  @override
  State<_CandidaturaFormView> createState() => _CandidaturaFormViewState();
}

class _CandidaturaFormViewState extends State<_CandidaturaFormView> {
  final _mensagemController = TextEditingController();
  final _validator = EnviarCandidaturaParamsValidators();
  final Map<String, String> _fieldErrors = {};
  late final EnviarCandidaturaParams _params = EnviarCandidaturaParams(vagaId: widget.args.vagaId, mensagem: '');

  @override
  void dispose() {
    _mensagemController.dispose();
    super.dispose();
  }

  void _submit() {
    final result = _validator.validate(_params);
    setState(() {
      _fieldErrors.clear();
      // Vários erros por campo: fica a primeira mensagem.
      for (final e in result.exceptions) {
        _fieldErrors.putIfAbsent(e.key, () => e.message);
      }
    });
    if (_fieldErrors.isNotEmpty) return;

    context.read<CandidaturaFormBloc>().add(CandidaturaSubmitted(params: _params));
  }

  void _clearError(String field) {
    if (_fieldErrors.containsKey(field)) {
      setState(() => _fieldErrors.remove(field));
    }
  }

  void _close() => context.canPop() ? context.pop() : context.go(AppPaths.vagaDetalhe(widget.args.vagaId));

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CandidaturaFormBloc, CandidaturaFormState>(
      listener: (context, state) {
        if (state is CandidaturaFormSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Candidatura enviada! Acompanhe o status por aqui.')));
          context.go(AppPaths.candidaturas);
        }
      },
      builder: (context, state) {
        final failure = state is CandidaturaFormFailure ? state.exception : null;
        final server = failure is ValidationException ? failure : null;
        final mensagemError = _fieldErrors['mensagem'] ?? server?.firstErrorFor('mensagem');
        final valorError = _fieldErrors['valorProposto'] ?? server?.firstErrorFor('valor_proposto');
        // Erros sem campo próprio (ex.: "Você já se candidatou", rede, vaga encerrada) vão para o aviso.
        final generalError = switch (failure) {
          null => null,
          ValidationException(fieldErrors: final f) when f.containsKey('mensagem') || f.containsKey('valor_proposto') => null,
          _ => failure.message,
        };

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.formMargin - 4, AppSpacing.md, AppSpacing.sm, 0),
                  child: Row(
                    children: [
                      Expanded(child: Text('Candidatar-se', style: AppTextStyles.titleSection.copyWith(fontSize: 26))),
                      IconButton(
                        tooltip: 'Fechar',
                        onPressed: _close,
                        icon: const Icon(Icons.close_rounded, size: 28, color: AppColors.ink),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(AppSpacing.formMargin - 4, AppSpacing.lg, AppSpacing.formMargin - 4, AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _VagaSummary(titulo: widget.args.titulo, resumo: widget.args.resumo),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          label: 'Mensagem',
                          controller: _mensagemController,
                          minLines: 6,
                          maxLines: 10,
                          maxLength: EnviarCandidaturaParamsValidators.mensagemMax,
                          showCounter: false,
                          keyboardType: TextInputType.multiline,
                          errorText: mensagemError,
                          onChanged: (value) {
                            _params.setMensagem(value);
                            _clearError('mensagem');
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text('Mínimo de ${EnviarCandidaturaParamsValidators.mensagemMin} caracteres', style: AppTextStyles.caption),
                            ),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _mensagemController,
                              builder: (context, value, _) =>
                                  Text('${value.text.length}/${EnviarCandidaturaParamsValidators.mensagemMax}', style: AppTextStyles.caption),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: 'Valor proposto',
                          labelSuffix: '(opcional)',
                          prefixText: 'R\$  ',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, BrlCurrencyInputFormatter()],
                          errorText: valorError,
                          onChanged: (value) {
                            _params.setValorProposto(BrlCurrencyInputFormatter.parse(value));
                            _clearError('valorProposto');
                          },
                        ),
                        if (generalError != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          ErrorBanner(message: generalError, onRetry: failure is NetworkException ? _submit : null),
                        ],
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.formMargin - 4, AppSpacing.md, AppSpacing.formMargin - 4, AppSpacing.lg),
                  decoration: const BoxDecoration(
                    color: AppColors.cream,
                    border: Border(top: BorderSide(color: AppColors.outline)),
                  ),
                  child: PrimaryButton(label: 'Enviar candidatura', isLoading: state is CandidaturaFormSubmitting, onPressed: _submit),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VagaSummary extends StatelessWidget {
  final String titulo;
  final String resumo;

  const _VagaSummary({required this.titulo, required this.resumo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.cardShape,
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AppTextStyles.titleSection.copyWith(fontSize: 21)),
          const SizedBox(height: AppSpacing.sm),
          Text(resumo, style: AppTextStyles.body.copyWith(color: AppColors.muted, fontSize: 15)),
        ],
      ),
    );
  }
}
