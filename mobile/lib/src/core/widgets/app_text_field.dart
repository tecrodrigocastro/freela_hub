import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final String? labelSuffix;
  final bool showCounter;
  final int? maxLength;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.labelSuffix,
    this.showCounter = true,
    this.maxLength,
    this.prefixText,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: AppTextStyles.label,
            children: [
              if (labelSuffix != null)
                TextSpan(text: ' $labelSuffix', style: AppTextStyles.weight(AppTextStyles.label.copyWith(color: AppColors.muted), FontWeight.w400)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: obscureText ? 1 : maxLines,
          minLines: obscureText ? null : minLines,
          maxLength: maxLength,
          enabled: enabled,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: AppTextStyles.body,
          cursorColor: AppColors.terra,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            prefixStyle: AppTextStyles.weight(AppTextStyles.body.copyWith(color: AppColors.muted), FontWeight.w700),
            counterText: showCounter ? null : '',
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
