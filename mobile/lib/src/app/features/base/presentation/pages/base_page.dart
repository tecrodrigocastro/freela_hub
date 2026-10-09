import 'package:base_clean_arch_bloc/src/app/features/base/presentation/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Casca das abas autenticadas: Vagas, Candidaturas e Perfil.
class BasePage extends StatelessWidget {
  const BasePage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: shell.currentIndex,
        // Tocar na aba atual volta para a raiz dela.
        onTap: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
      ),
    );
  }
}
