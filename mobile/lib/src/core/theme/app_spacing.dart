import 'package:flutter/material.dart';

/// Espaçamento (múltiplos de 4), raios e alvo mínimo de toque.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Margem lateral de listas (16) e formulários (24).
  static const double pageMargin = lg;
  static const double formMargin = xl;

  static const double minTouchTarget = 44;
}

abstract final class AppRadius {
  static const double button = 12;
  static const double input = 12;
  static const double card = 16;
  static const double chip = 999;

  static final buttonShape = BorderRadius.circular(button);
  static final cardShape = BorderRadius.circular(card);
  static final chipShape = BorderRadius.circular(chip);
}
