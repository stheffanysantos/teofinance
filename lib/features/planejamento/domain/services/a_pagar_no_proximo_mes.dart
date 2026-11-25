import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/services/proxima_ocorrencia.dart';

enum TipoItemAPagar { cartao, conta }

/// Uma saída do mês seguinte: uma fatura de cartão (sua parte) ou uma conta.
class ItemAPagar {
  const ItemAPagar({required this.descricao, required this.vencimento, required this.valor, required this.tipo});

  final String descricao;
  final DateTime vencimento;
  final double valor;
  final TipoItemAPagar tipo;
}

/// O que o usuário terá de pagar no mês seguinte ao de [hoje].
class APagarNoProximoMes {
  const APagarNoProximoMes({required this.ano, required this.mes, required this.cartoes, required this.contas, this.itens = const []});

  final int ano;
  final int mes;

  /// Só a parte do usuário nas faturas que vencem no mês.
  final double cartoes;

  /// Contas a pagar em aberto que vencem no mês (as que se repetem contam de novo).
  final double contas;

  /// Cada fatura e cada conta, em ordem de vencimento.
  final List<ItemAPagar> itens;

  double get total => cartoes + contas;
}

/// Soma, para o mês seguinte: a parte do usuário nas faturas de cartão que vencem
/// nele e as contas a pagar em aberto com vencimento nele.
APagarNoProximoMes calcularAPagarNoProximoMes({
  required DateTime hoje,
  required List<MesDeFaturas> faturas,
  required List<ContaAPagar> contas,
}) {
  final alvo = DateTime(hoje.year, hoje.month + 1);
  final fim = DateTime(alvo.year, alvo.month + 1, 0);

  final itens = <ItemAPagar>[];
  var doCartao = 0.0;
  for (final m in faturas) {
    if (m.ano != alvo.year || m.mes != alvo.month) continue;
    for (final f in m.faturas) {
      doCartao += f.minhaParte;
      itens.add(ItemAPagar(
        descricao: 'Fatura ${f.cartao.nome}',
        vencimento: f.vencimento,
        valor: f.minhaParte,
        tipo: TipoItemAPagar.cartao,
      ));
    }
  }

  var dasContas = 0.0;
  for (final c in contas) {
    if (c.paga) continue;
    var venc = DateTime(c.vencimento.year, c.vencimento.month, c.vencimento.day);
    var passo = 0;
    while (!venc.isAfter(fim) && passo < 36) {
      if (venc.year == alvo.year && venc.month == alvo.month) {
        dasContas += c.valor;
        itens.add(ItemAPagar(descricao: c.descricao, vencimento: venc, valor: c.valor, tipo: TipoItemAPagar.conta));
      }
      final proximo = proximoVencimento(vencimento: venc, diaBase: c.diaBase, recorrencia: c.recorrencia);
      if (proximo == null) break;
      venc = proximo;
      passo++;
    }
  }

  itens.sort((a, b) => a.vencimento.compareTo(b.vencimento));
  return APagarNoProximoMes(ano: alvo.year, mes: alvo.month, cartoes: doCartao, contas: dasContas, itens: itens);
}
