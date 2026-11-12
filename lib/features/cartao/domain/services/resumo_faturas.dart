import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/periodo_fatura.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

/// Uma fatura de um cartão: o que o banco cobra e se já foi paga.
class ResumoFatura {
  const ResumoFatura({required this.ano, required this.mes, required this.periodo, required this.total, this.paga});

  final int ano;
  final int mes;
  final PeriodoFatura periodo;

  /// O que o banco cobra: compras menos estornos.
  final double total;
  final FaturaPaga? paga;

  bool get emAberto => paga == null && total > 0;

  bool vencidaEm(DateTime hoje) => emAberto && periodo.vencimento.isBefore(DateTime(hoje.year, hoje.month, hoje.day));
}

/// Todas as faturas do [cartao] que têm compras, da mais antiga para a mais
/// nova. Faturas pagas depois do vencimento (ou ainda não pagas) aparecem como
/// qualquer outra: o que decide "em aberto" é existir ou não um pagamento.
List<ResumoFatura> resumirFaturas({
  required Cartao cartao,
  required List<Transacao> transacoes,
  required List<FaturaPaga> pagamentos,
}) {
  final totais = <({int ano, int mes}), double>{};
  for (final t in transacoes) {
    if (t.cartaoId != cartao.id) continue;
    final ref = faturaDaData(diaFechamento: cartao.diaFechamento, diaVencimento: cartao.diaVencimento, data: t.data);
    totais[ref] = (totais[ref] ?? 0) - t.valorCobrado;
  }

  final lista = [
    for (final e in totais.entries)
      ResumoFatura(
        ano: e.key.ano,
        mes: e.key.mes,
        periodo: periodoDaFatura(
          diaFechamento: cartao.diaFechamento,
          diaVencimento: cartao.diaVencimento,
          ano: e.key.ano,
          mes: e.key.mes,
        ),
        total: e.value,
        paga: pagamentos
            .where((p) => p.cartaoId == cartao.id && p.ano == e.key.ano && p.mes == e.key.mes)
            .firstOrNull,
      ),
  ]..sort((a, b) => a.periodo.vencimento.compareTo(b.periodo.vencimento));
  return lista;
}

/// Quanto o usuário já gastou no crédito e o banco ainda não descontou da conta:
/// a parte dele nas compras de faturas em aberto de todos os [cartoes]. Usa a
/// mesma regra do saldo (compra dividida = só a parte dele), por isso é o que
/// separa "saldo na conta" de "saldo após faturas" sem sobrar nem faltar a
/// parte de quem dividiu a compra.
double parteEmAbertoNosCartoes({
  required List<Cartao> cartoes,
  required List<Transacao> transacoes,
  required List<FaturaPaga> pagamentos,
}) {
  var total = 0.0;
  for (final c in cartoes) {
    final abertas = {
      for (final f in resumirFaturas(cartao: c, transacoes: transacoes, pagamentos: pagamentos))
        if (f.emAberto) (ano: f.ano, mes: f.mes),
    };
    if (abertas.isEmpty) continue;
    for (final t in transacoes) {
      if (t.cartaoId != c.id) continue;
      final fatura = faturaDaData(diaFechamento: c.diaFechamento, diaVencimento: c.diaVencimento, data: t.data);
      if (abertas.contains(fatura)) total -= t.valorNoSaldo;
    }
  }
  return total;
}
