/// Formatação de valores monetários em padrão BR — usado por qualquer
/// feature que exiba um valor financeiro (evita duplicar a lógica).
String formatCurrency(double value, {bool comSinal = false}) {
  final sign = comSinal ? (value < 0 ? '− ' : '+ ') : (value < 0 ? '-' : '');
  final abs = value.abs();
  final cents = (abs * 100).round() % 100;
  final intPart = abs.truncate();
  final intStr = intPart.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => '.',
  );
  return '$sign'
      'R\$ $intStr,${cents.toString().padLeft(2, '0')}';
}

/// Mesma formatação, sempre com sinal (+ / −) — usado em listas de
/// transações, onde o sinal comunica receita vs. despesa.
String formatCurrencyDelta(double value) => formatCurrency(value, comSinal: true);
