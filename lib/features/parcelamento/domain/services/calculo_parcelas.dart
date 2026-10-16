import 'dart:math' as math;

/// Vencimento da parcela de índice [indice] (0 = primeira): mesmo dia do mês
/// da primeira parcela, ou o último dia do mês quando ele é mais curto
/// (31/jan → 28/fev → 31/mar).
DateTime dataDaParcela(DateTime primeira, int indice) {
  final primeiroDoMes = DateTime(primeira.year, primeira.month + indice);
  final ultimoDia = DateTime(primeiroDoMes.year, primeiroDoMes.month + 1, 0).day;
  return DateTime(
    primeiroDoMes.year,
    primeiroDoMes.month,
    math.min(primeira.day, ultimoDia),
    primeira.hour,
    primeira.minute,
    primeira.second,
  );
}

/// Divide [total] em [numeroParcelas] valores em centavos que somam exatamente
/// o total; o resto da divisão vai para a última parcela (100 em 3x →
/// 33,33 + 33,33 + 33,34). O sinal de [total] é mantido em todas as parcelas.
List<double> valoresDasParcelas(double total, int numeroParcelas) {
  final centavos = (total.abs() * 100).round();
  final base = centavos ~/ numeroParcelas;
  final resto = centavos - base * numeroParcelas;
  final sinal = total < 0 ? -1 : 1;

  return [
    for (var i = 0; i < numeroParcelas; i++)
      sinal * (i == numeroParcelas - 1 ? base + resto : base) / 100,
  ];
}
