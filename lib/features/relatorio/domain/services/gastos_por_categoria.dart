import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

/// Quanto se gastou em uma categoria no mês.
class GastoCategoria {
  const GastoCategoria({
    required this.categoria,
    required this.valor,
    this.valorAnterior = 0,
  });

  final String categoria;
  final double valor;

  /// Quanto se gastou na mesma categoria no mês anterior.
  final double valorAnterior;

  /// Variação em relação ao mês anterior, em %. Nulo quando não havia gasto
  /// antes (não existe base para comparar).
  double? get variacaoPercent =>
      valorAnterior <= 0 ? null : (valor - valorAnterior) / valorAnterior * 100;
}

/// Ranking das categorias em que mais se gastou no mês de [hoje], da maior para
/// a menor, já comparando com o mês anterior. Considera o que pesa para o
/// usuário (compra dividida = só a parte dele), descarta receitas e o ajuste
/// de saldo, e agrupa o que não tem categoria em "Sem categoria".
List<GastoCategoria> gastosPorCategoriaDoMes(
  List<Transacao> transacoes,
  DateTime hoje,
) {
  final anterior = DateTime(hoje.year, hoje.month - 1);
  final atual = _somar(transacoes, hoje);
  final passado = _somar(transacoes, anterior);
  return [
    for (final e in atual.entries)
      GastoCategoria(
        categoria: e.key,
        valor: e.value,
        valorAnterior: passado[e.key] ?? 0,
      ),
  ]..sort((a, b) => b.valor.compareTo(a.valor));
}

Map<String, double> _somar(List<Transacao> transacoes, DateTime mes) {
  final soma = <String, double>{};
  for (final t in transacoes) {
    if (t.categoria == kCategoriaAjusteSaldo) continue;
    if (t.data.year != mes.year || t.data.month != mes.month) continue;
    final v = t.valorContabilizado;
    if (v >= 0) continue;
    final nome = t.precisaCategoria ? 'Sem categoria' : t.categoria;
    soma[nome] = (soma[nome] ?? 0) - v;
  }
  return soma;
}
