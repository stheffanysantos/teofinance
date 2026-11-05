import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

/// Receitas e despesas de um mês.
class FluxoMes {
  const FluxoMes({
    required this.ano,
    required this.mes,
    required this.receitas,
    required this.despesas,
  });

  final int ano;
  final int mes;
  final double receitas;
  final double despesas;

  double get saldo => receitas - despesas;
}

/// Os [meses] últimos meses até [hoje] (o atual por último). Usa o valor que
/// pesa para o usuário (compra dividida = só a parte dele) e ignora o ajuste de
/// saldo, que não é dinheiro que entrou ou saiu.
List<FluxoMes> calcularFluxoMensal(
  List<Transacao> transacoes,
  DateTime hoje, {
  int meses = 6,
}) {
  return [
    for (var i = meses - 1; i >= 0; i--)
      () {
        final ref = DateTime(hoje.year, hoje.month - i);
        var receitas = 0.0;
        var despesas = 0.0;
        for (final t in transacoes) {
          if (t.categoria == kCategoriaAjusteSaldo) continue;
          if (t.data.year != ref.year || t.data.month != ref.month) continue;
          final v = t.valorContabilizado;
          if (v > 0) {
            receitas += v;
          } else {
            despesas += -v;
          }
        }
        return FluxoMes(
          ano: ref.year,
          mes: ref.month,
          receitas: receitas,
          despesas: despesas,
        );
      }(),
  ];
}
