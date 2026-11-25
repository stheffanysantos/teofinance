import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/periodo_fatura.dart';
import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/parcelamento/domain/services/calculo_parcelas.dart';

/// Efeito de uma parcela da compra simulada na fatura de um mês.
class ImpactoNoMes {
  const ImpactoNoMes({required this.ano, required this.mes, required this.jaComprometido, required this.parcela});

  /// Mês e ano do vencimento da fatura.
  final int ano;
  final int mes;

  /// O que já vence neste mês nos cartões, antes da compra.
  final double jaComprometido;
  final double parcela;

  double get depois => jaComprometido + parcela;
}

class SimulacaoDeParcelamento {
  const SimulacaoDeParcelamento({
    required this.meses,
    required this.valorTotal,
    this.limite,
    this.usoDoLimiteDepois,
  });

  final List<ImpactoNoMes> meses;
  final double valorTotal;
  final double? limite;

  /// Quanto do limite do cartão estaria usado com a compra (faturas em aberto + ela).
  final double? usoDoLimiteDepois;

  bool get ultrapassaLimite => limite != null && usoDoLimiteDepois != null && usoDoLimiteDepois! > limite!;
  double get valorDaParcela => meses.isEmpty ? 0 : meses.first.parcela;

  /// O mês em que a fatura fica mais pesada com a compra.
  ImpactoNoMes? get mesMaisPesado => meses.isEmpty ? null : meses.reduce((a, b) => b.depois > a.depois ? b : a);
}

/// Mostra como ficariam as faturas dos próximos meses se [valor] fosse parcelado
/// em [parcelas] vezes no [cartao], comprado em [dataCompra]. As [faturas] são
/// as já em aberto (de todos os cartões), para somar com o que já está
/// comprometido. A primeira parcela cai na fatura em que a compra de [dataCompra]
/// entraria.
SimulacaoDeParcelamento simularParcelamento({
  required double valor,
  required int parcelas,
  required Cartao cartao,
  required DateTime dataCompra,
  required List<MesDeFaturas> faturas,
}) {
  if (valor <= 0 || parcelas < 1) return const SimulacaoDeParcelamento(meses: [], valorTotal: 0);

  final valores = valoresDasParcelas(valor, parcelas);
  final primeira = faturaDaData(diaFechamento: cartao.diaFechamento, diaVencimento: cartao.diaVencimento, data: dataCompra);

  double comprometido(int ano, int mes) {
    for (final m in faturas) {
      if (m.ano == ano && m.mes == mes) return m.total;
    }
    return 0;
  }

  final meses = <ImpactoNoMes>[];
  for (var i = 0; i < parcelas; i++) {
    final ref = DateTime(primeira.ano, primeira.mes + i);
    meses.add(
      ImpactoNoMes(
        ano: ref.year,
        mes: ref.month,
        jaComprometido: comprometido(ref.year, ref.month),
        parcela: valores[i],
      ),
    );
  }

  double? uso;
  if (cartao.limite != null) {
    var aberto = 0.0;
    for (final m in faturas) {
      for (final f in m.faturas) {
        if (f.cartao.id == cartao.id) aberto += f.total;
      }
    }
    uso = aberto + valor;
  }

  return SimulacaoDeParcelamento(meses: meses, valorTotal: valor, limite: cartao.limite, usoDoLimiteDepois: uso);
}
