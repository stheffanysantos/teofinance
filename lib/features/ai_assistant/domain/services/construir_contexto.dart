import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/services/calcular_envelopes.dart';
import 'package:teofinance/features/meta/domain/entities/meta.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

/// Reduz os dados das outras features ao agregado do mês [mes].
ContextoFinanceiro construirContexto({
  required List<Transacao> transacoes,
  required List<Orcamento> limites,
  required List<Meta> metas,
  required DateTime mes,
}) {
  var receitas = 0.0;
  var despesas = 0.0;
  final porCategoria = <String, double>{};

  for (final t in transacoes) {
    if (t.data.year != mes.year || t.data.month != mes.month) continue;
    final valor = t.valorContabilizado;
    if (valor > 0) {
      receitas += valor;
    } else if (valor < 0) {
      despesas -= valor;
      final categoria = t.categoria.trim().isEmpty ? 'Sem categoria' : t.categoria;
      porCategoria.update(categoria, (atual) => atual - valor, ifAbsent: () => -valor);
    }
  }

  return ContextoFinanceiro(
    mes: mes,
    receitas: receitas,
    despesas: despesas,
    gastoPorCategoria: porCategoria,
    envelopes: calcularEnvelopes(limites: limites, transacoes: transacoes, mes: mes).envelopes,
    metas: metas,
  );
}
