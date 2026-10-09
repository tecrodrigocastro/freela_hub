import 'package:base_clean_arch_bloc/src/core/utils/app_paths.dart';
import 'package:base_clean_arch_bloc/src/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:base_clean_arch_bloc/src/core/DI/dependency_injector.dart';
import 'package:base_clean_arch_bloc/src/core/theme/theme.dart';
import 'package:base_clean_arch_bloc/src/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const minDuration = Duration(milliseconds: 1600);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AuthBloc _bloc = injector<AuthBloc>();
  late final AnimationController _progress =
      AnimationController(vsync: this, duration: SplashPage.minDuration);

  @override
  void initState() {
    super.initState();
    _progress.forward();
    _resolveDestination();
  }

  Future<void> _resolveDestination() async {
    // Assina antes de disparar o evento para não perder a emissão.
    final resolved = _bloc.stream
        .firstWhere((s) => s is AuthAuthenticated || s is AuthUnauthenticated);
    _bloc.add(const AuthSessionChecked());

    final state = await resolved;
    await Future<void>.delayed(SplashPage.minDuration);

    if (!mounted) return;
    context.go(state is AuthAuthenticated ? AppPaths.vagas : AppPaths.login);
  }

  @override
  void dispose() {
    _progress.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 5),
            const BrandMark(size: 88),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'FreelaHub',
              style: AppTextStyles.titleScreen
                  .copyWith(color: AppColors.cream, fontSize: 40),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Quadro de vagas freelance',
              style: AppTextStyles.weight(
                AppTextStyles.body.copyWith(color: AppColors.gold, fontSize: 18),
                FontWeight.w600,
              ),
            ),
            const Spacer(flex: 6),
            AnimatedBuilder(
              animation: _progress,
              builder: (context, _) => ClipRRect(
                borderRadius: AppRadius.chipShape,
                child: SizedBox(
                  width: 120,
                  height: 4,
                  child: LinearProgressIndicator(
                    value: _progress.value,
                    backgroundColor: const Color(0xFF442A19),
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
