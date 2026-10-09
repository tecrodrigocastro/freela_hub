import 'package:flutter/material.dart';

/// Tokens de cor do FreelaHub (docs/SCREENS.md · Design System).
abstract final class AppColors {
  static const ink = Color(0xFF4A2E1E);
  static const terra = Color(0xFFC2601D);
  static const gold = Color(0xFFE8961E);
  static const dark = Color(0xFF2B1B10);
  static const muted = Color(0xFF6B5738);

  static const cream = Color(0xFFFBEFD3);
  static const cream2 = Color(0xFFF3DFAE);
  static const card = Color(0xFFFCF3DC);
  static const outline = Color(0xFFD9C28E);
  static const terraText = Color(0xFFA04E15);

  static const success = Color(0xFF4C7A34);
  static const danger = Color(0xFFA63D2F);

  /// Fundos suaves dos chips de status.
  static const successSoft = Color(0xFFDCE8CF);
  static const dangerSoft = Color(0xFFF1D3CD);
  static const goldSoft = Color(0xFFF7DDA6);

  /// Botão desabilitado (ex.: "Candidatura enviada").
  static const terraDisabled = Color(0xFFE3C4A8);
  static const terraDisabledText = Color(0xFF8A6A4F);
}
