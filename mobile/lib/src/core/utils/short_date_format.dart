const _months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];

/// `2026-10-03` → `03 out 2026`. Tabela própria: não depende de `initializeDateFormatting`.
String formatShortDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')} ${_months[local.month - 1]} ${local.year}';
}
