import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:flutter/material.dart';

class VagasSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const VagasSearchField({super.key, required this.controller, required this.onChanged, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.body,
      cursorColor: AppColors.terra,
      decoration: InputDecoration(
        hintText: 'Buscar por título ou descrição',
        hintStyle: AppTextStyles.body.copyWith(color: const Color(0xFF9C9486)),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.ink),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Limpar busca',
                  icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                  onPressed: () {
                    controller.clear();
                    onSubmitted('');
                  },
                ),
        ),
      ),
    );
  }
}
