import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/periodo_fatura.dart';
import 'package:teofinance/features/cartao/domain/services/resumo_faturas.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

/// A fatura em aberto de um cartão que vence num determinado mês.
class FaturaDoCartaoNoMes {
  const FaturaDoCartaoNoMes({
    required this.cartao,
    required this.total,
    required this.minhaParte,
    required this.vencimento,
    required this.vencida,
  });

  final Cartao cartao;

  /// O que o banco cobra nesta fatura.
  final double total;

  /// Quanto disso é do usuário: nas compras divididas só a parte dele.
  final double minhaParte;
  final DateTime vencimento;
  final bool vencida;

  bool get temDivisao => (total - minhaParte).abs() > 0.005;
}

/// O que vence num mês, somando as faturas em aberto de todos os cartões.
class MesDeFaturas {
  const MesDeFaturas({required this.ano, required this.mes, required this.faturas});

  /// Mês e ano do vencimento.
  final int ano;
  final int mes;

  /// Uma por cartão, da que vence primeiro para a última.
  final List<FaturaDoCartaoNoMes> faturas;

  double get total => faturas.fold(0.0, (a, f) => a + f.total);
  double get minhaParte => faturas.fold(0.0, (a, f) => a + f.minhaParte);
  bool get temDivisao => faturas.any((f) => f.temDivisao);
  bool get vencida => faturas.any((f) => f.vencida);

  /// Primeiro vencimento do mês, para ordenar e rotular.
  DateTime get primeiroVencimento =>
      faturas.map((f) => f.vencimento).reduce((a, b) => a.isBefore(b) ? a : b);
}

/// Dívida nos cartões separada pelo mês de vencimento: todas as faturas ainda
/// não pagas, de todos os cartões, do mês mais antigo para o mais distante.
/// Parcelas futuras já caem no mês certo, porque cada parcela é uma transação
/// com a sua data. Faturas pagas ou sem compras ficam de fora.
List<MesDeFaturas> projetarFaturasPorMes({
  required List<Cartao> cartoes,
  required List<Transacao> transacoes,
  required List<FaturaPaga> pagamentos,
  required DateTime hoje,
}) {
  final porMes = <({int ano, int mes}), List<FaturaDoCartaoNoMes>>{};

  for (final c in cartoes) {
    final abertas = resumirFaturas(cartao: c, transacoes: transacoes, pagamentos: pagamentos).where((f) => f.emAberto);

    // A parte do usuário por fatura, com a mesma regra do saldo.
    final minhaParte = <({int ano, int mes}), double>{};
    for (final t in transacoes) {
      if (t.cartaoId != c.id) continue;
      final ref = faturaDaData(diaFechamento: c.diaFechamento, diaVencimento: c.diaVencimento, data: t.data);
      minhaParte.update(ref, (v) => v - t.valorNoSaldo, ifAbsent: () => -t.valorNoSaldo);
    }

    for (final f in abertas) {
      final chave = (ano: f.ano, mes: f.mes);
      porMes.putIfAbsent(chave, () => []).add(
        FaturaDoCartaoNoMes(
          cartao: c,
          total: f.total,
          minhaParte: minhaParte[chave] ?? f.total,
          vencimento: f.periodo.vencimento,
          vencida: f.vencidaEm(hoje),
        ),
      );
    }
  }

  final meses = [
    for (final e in porMes.entries)
      MesDeFaturas(
        ano: e.key.ano,
        mes: e.key.mes,
        faturas: [...e.value]..sort((a, b) => a.vencimento.compareTo(b.vencimento)),
      ),
  ]..sort((a, b) => DateTime(a.ano, a.mes).compareTo(DateTime(b.ano, b.mes)));
  return meses;
}
