import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

/// Resumo de um mês de transações, pronto para virar PDF ou CSV.
/// Valores usam `valorContabilizado`: numa compra dividida, só a parte do usuário.
class RelatorioMensal {
  const RelatorioMensal({
    required this.ano,
    required this.mes,
    required this.transacoes,
    required this.receitas,
    required this.despesas,
    required this.despesasPorCategoria,
  });

  factory RelatorioMensal.de(
    List<Transacao> todas, {
    required int ano,
    required int mes,
  }) {
    final doMes =
        todas
            .where(
              (t) =>
                  t.data.year == ano &&
                  t.data.month == mes &&
                  t.categoria != kCategoriaAjusteSaldo,
            )
            .toList()
          ..sort((a, b) => a.data.compareTo(b.data));

    var receitas = 0.0;
    var despesas = 0.0;
    final porCategoria = <String, double>{};
    for (final t in doMes) {
      final valor = t.valorContabilizado;
      if (valor > 0) {
        receitas += valor;
      } else {
        despesas += -valor;
        final categoria = t.precisaCategoria ? semCategoria : t.categoria;
        porCategoria[categoria] = (porCategoria[categoria] ?? 0) + -valor;
      }
    }

    final ordenado = porCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return RelatorioMensal(
      ano: ano,
      mes: mes,
      transacoes: doMes,
      receitas: receitas,
      despesas: despesas,
      despesasPorCategoria: Map.fromEntries(ordenado),
    );
  }

  static const semCategoria = 'Sem categoria';

  final int ano;
  final int mes;

  /// Em ordem cronológica.
  final List<Transacao> transacoes;
  final double receitas;

  /// Positivo: soma do que saiu.
  final double despesas;

  /// Da maior para a menor despesa.
  final Map<String, double> despesasPorCategoria;

  double get saldo => receitas - despesas;
  bool get vazio => transacoes.isEmpty;
}
