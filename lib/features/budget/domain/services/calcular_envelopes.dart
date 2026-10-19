import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

/// Cruza os limites com as despesas do mês [mes] (qualquer dia do mês serve).
///
/// O gasto de uma categoria soma só despesas (`valorContabilizado < 0`) e usa
/// a parte do usuário nas compras divididas. Parcelas entram no mês em que
/// vencem, pois cada parcela é uma transação com a própria data.
ResumoOrcamento calcularEnvelopes({
  required List<Orcamento> limites,
  required List<Transacao> transacoes,
  required DateTime mes,
}) {
  final gastoPorCategoria = <String, double>{};
  for (final t in transacoes) {
    if (t.data.year != mes.year || t.data.month != mes.month) continue;
    if (t.valorContabilizado >= 0) continue;
    gastoPorCategoria.update(
      t.categoria,
      (atual) => atual - t.valorContabilizado,
      ifAbsent: () => -t.valorContabilizado,
    );
  }

  final ordenados = [...limites]..sort((a, b) => a.categoria.compareTo(b.categoria));
  return ResumoOrcamento([
    for (final o in ordenados)
      EnvelopeOrcamento(orcamento: o, gasto: gastoPorCategoria[o.categoria] ?? 0),
  ]);
}
