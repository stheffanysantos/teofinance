/// Janela de compras de uma fatura: de [inicio] (inclusive) até [fim]
/// (exclusive, é o dia do fechamento — compra nesse dia entra na próxima fatura,
/// por isso é o "melhor dia de compra") e a data de [vencimento].
class PeriodoFatura {
  const PeriodoFatura({required this.inicio, required this.fim, required this.vencimento});

  final DateTime inicio;
  final DateTime fim;
  final DateTime vencimento;

  bool contem(DateTime data) {
    final d = DateTime(data.year, data.month, data.day);
    return !d.isBefore(inicio) && d.isBefore(fim);
  }
}

DateTime _diaDoMes(int ano, int mes, int dia) {
  final base = DateTime(ano, mes);
  final ultimo = DateTime(base.year, base.month + 1, 0).day;
  return DateTime(base.year, base.month, dia > ultimo ? ultimo : dia);
}

/// Período da fatura que vence em [mes]/[ano]. Se o vencimento é depois do
/// fechamento no calendário (fecha dia 5, vence dia 12) o ciclo fecha no mesmo
/// mês do vencimento; senão (fecha dia 25, vence dia 5) fechou no mês anterior.
PeriodoFatura periodoDaFatura({
  required int diaFechamento,
  required int diaVencimento,
  required int ano,
  required int mes,
}) {
  final mesDoFechamento = diaVencimento > diaFechamento ? mes : mes - 1;
  return PeriodoFatura(
    inicio: _diaDoMes(ano, mesDoFechamento - 1, diaFechamento),
    fim: _diaDoMes(ano, mesDoFechamento, diaFechamento),
    vencimento: _diaDoMes(ano, mes, diaVencimento),
  );
}

/// Mês (ano, mês) do vencimento da fatura que está aberta em [hoje]: a primeira
/// cujo fechamento ainda não passou.
({int ano, int mes}) faturaAberta({
  required int diaFechamento,
  required int diaVencimento,
  required DateTime hoje,
}) {
  var ref = (ano: hoje.year, mes: hoje.month);
  for (var i = 0; i < 3; i++) {
    final p = periodoDaFatura(diaFechamento: diaFechamento, diaVencimento: diaVencimento, ano: ref.ano, mes: ref.mes);
    if (p.contem(hoje)) return ref;
    final prox = DateTime(ref.ano, ref.mes + 1);
    ref = (ano: prox.year, mes: prox.month);
  }
  return (ano: hoje.year, mes: hoje.month);
}

/// Fatura (mês/ano do vencimento) em que uma compra feita em [data] entra.
({int ano, int mes}) faturaDaData({
  required int diaFechamento,
  required int diaVencimento,
  required DateTime data,
}) {
  return faturaAberta(diaFechamento: diaFechamento, diaVencimento: diaVencimento, hoje: data);
}
