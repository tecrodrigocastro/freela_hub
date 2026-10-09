import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Máscara de reais para o campo de valor: digitar `420000` mostra `4.200,00`.
/// O `R$` fica no prefixo do campo.
class BrlCurrencyInputFormatter extends TextInputFormatter {
  static final _number = NumberFormat.decimalPatternDigits(locale: 'pt_BR', decimalDigits: 2);

  /// `4.200,00` → `4200.0`; vazio → `null`.
  static double? parse(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? null : int.parse(digits) / 100;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();

    final text = _number.format(int.parse(digits) / 100);
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
