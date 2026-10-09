import 'package:base_clean_arch_bloc/src/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Tipografia: Libre Baskerville nos títulos, Public Sans no corpo.
abstract final class AppTextStyles {
  /// Troca o peso de um estilo. As fontes são variáveis (um único TTF), então o
  /// peso precisa ir também no eixo `wght`; só `fontWeight` deixaria o padrão (fino).
  static TextStyle weight(TextStyle style, FontWeight weight) => style.copyWith(
        fontWeight: weight,
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
      );

  static const _serif = 'LibreBaskerville';
  static const _sans = 'PublicSans';

  static const titleScreen = TextStyle(
    fontFamily: _serif,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700.0)],
    color: AppColors.ink,
    height: 1.2,
  );
  static const titleTab = TextStyle(
    fontFamily: _serif,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700.0)],
    color: AppColors.ink,
    height: 1.2,
  );
  static const titleSection = TextStyle(
    fontFamily: _serif,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700.0)],
    color: AppColors.ink,
    height: 1.3,
  );
  static const titleCard = TextStyle(
    fontFamily: _serif,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700.0)],
    color: AppColors.ink,
    height: 1.3,
  );

  static const button = TextStyle(
    fontFamily: _sans,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700.0)],
  );
  static const body = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400.0)],
    color: AppColors.ink,
    height: 1.5,
  );
  static const label = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600.0)],
    color: AppColors.ink,
  );
  static const caption = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400.0)],
    color: AppColors.muted,
  );
  static const chip = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700.0)],
    color: AppColors.ink,
  );

  static const textTheme = TextTheme(
    displayLarge: titleScreen,
    headlineLarge: titleScreen,
    headlineMedium: titleTab,
    titleLarge: titleSection,
    titleMedium: titleCard,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: label,
    labelMedium: label,
    labelSmall: chip,
  );
}
