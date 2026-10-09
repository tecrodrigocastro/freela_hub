import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Casca comum de Login e Cadastro: conteúdo rolável com margem de 24 e
/// rodapé com o link para a outra tela.
class AuthScaffold extends StatelessWidget {
  final Widget? header;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final String footerText;
  final String footerAction;
  final VoidCallback onFooterTap;

  const AuthScaffold({
    super.key,
    this.header,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.footerText,
    required this.footerAction,
    required this.onFooterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.formMargin),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xxl + AppSpacing.md),
                    if (header != null) ...[
                      Align(alignment: Alignment.centerLeft, child: header),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Text(title, style: AppTextStyles.titleScreen),
                    const SizedBox(height: AppSpacing.md),
                    Text(subtitle,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.muted, fontSize: 17)),
                    const SizedBox(height: AppSpacing.xxl),
                    ...children,
                    const Spacer(),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(
                        child: InkWell(
                          onTap: onFooterTap,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minHeight: AppSpacing.minTouchTarget),
                            child: Center(
                              widthFactor: 1,
                              child: Text.rich(
                                TextSpan(
                                  style: AppTextStyles.body
                                      .copyWith(color: AppColors.muted),
                                  children: [
                                    TextSpan(text: '$footerText '),
                                    TextSpan(
                                      text: footerAction,
                                      style: AppTextStyles.weight(
                                        const TextStyle(color: AppColors.terraText),
                                        FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
