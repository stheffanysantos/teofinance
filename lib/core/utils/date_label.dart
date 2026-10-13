const kMesesAbreviados = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

/// "Hoje" / "Ontem" / "dd mmm" — usado em qualquer lista de transações.
String rotuloDataRelativa(DateTime data) {
  final agora = DateTime.now();
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final dia = DateTime(data.year, data.month, data.day);
  final diferenca = hoje.difference(dia).inDays;

  if (diferenca == 0) return 'Hoje';
  if (diferenca == 1) return 'Ontem';
  return '${data.day.toString().padLeft(2, '0')} ${kMesesAbreviados[data.month - 1]}';
}
