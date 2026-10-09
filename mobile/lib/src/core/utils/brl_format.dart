import 'package:intl/intl.dart';

final _brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

/// `4200` → `R$ 4.200` (sem centavos, como nos cards do design).
String formatBrl(double value) => _brl.format(value).replaceAll(' ', ' ');
