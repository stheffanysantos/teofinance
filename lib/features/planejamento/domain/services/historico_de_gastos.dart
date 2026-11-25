import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

/// Nome usado para despesas sem categoria.
const kCategoriaOutros = 'Outros';

/// Quanto o usuário costuma gastar por mês, olhando os meses fechados antes do
/// mês de [hoje]. Só conta despesas, e nas compras divididas só a parte dele.
class HistoricoDeGastos {
  const HistoricoDeGastos({required this.mediaPorCategoria, required this.mesesComDados});

  /// Gasto médio mensal em cada categoria.
  final Map<String, double> mediaPorCategoria;

  /// Quantos dos meses olhados tinham alguma despesa (a média divide por isso).
  final int mesesComDados;

  double get mediaTotal => mediaPorCategoria.values.fold(0.0, (a, b) => a + b);
  bool get semDados => mesesComDados == 0;
}

/// Média mensal por categoria dos [meses] meses completos anteriores a [hoje].
HistoricoDeGastos calcularHistoricoDeGastos(
  List<Transacao> transacoes, {
  required DateTime hoje,
  int meses = 3,
}) {
  final inicio = DateTime(hoje.year, hoje.month - meses);
  final fim = DateTime(hoje.year, hoje.month); // exclusive: o mês atual não conta

  final total = <String, double>{};
  final mesesVistos = <(int, int)>{};

  for (final t in transacoes) {
    if (t.data.isBefore(inicio) || !t.data.isBefore(fim)) continue;
    if (t.categoria == kCategoriaAjusteSaldo) continue;
    final valor = t.valorContabilizado;
    if (valor >= 0) continue;

    mesesVistos.add((t.data.year, t.data.month));
    final categoria = t.categoria.trim().isEmpty ? kCategoriaOutros : t.categoria.trim();
    total.update(categoria, (v) => v - valor, ifAbsent: () => -valor);
  }

  if (mesesVistos.isEmpty) return const HistoricoDeGastos(mediaPorCategoria: {}, mesesComDados: 0);

  final n = mesesVistos.length;
  return HistoricoDeGastos(
    mediaPorCategoria: {for (final e in total.entries) e.key: e.value / n},
    mesesComDados: n,
  );
}
