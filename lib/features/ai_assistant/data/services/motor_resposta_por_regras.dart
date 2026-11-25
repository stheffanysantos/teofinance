import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/utils/date_label.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';
import 'package:teofinance/features/ai_assistant/domain/services/motor_resposta.dart';
import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';

/// Responde por regras determinísticas sobre o [ContextoFinanceiro] — sem
/// modelo e sem rede. Serve de motor padrão e de fallback quando o Gemma local
/// não estiver disponível (ver `.claude/agents/ai-assistant-engineer.md`).
class MotorRespostaPorRegras implements MotorResposta {
  const MotorRespostaPorRegras();

  @override
  Future<Either<Failure, String>> responder({
    required String pergunta,
    required ContextoFinanceiro contexto,
  }) async {
    final q = _normalizar(pergunta);
    final mes = kMesesPorExtenso[contexto.mes.month - 1];

    // Assuntos além do mês corrente vêm primeiro: "fatura" ou "investimento"
    // não podem cair numa categoria de mesmo nome criada pelo usuário.
    final pessoa = contexto.reembolsos.keys.where((p) => q.contains(_normalizar(p))).firstOrNull;
    if (pessoa != null || _citaAlgum(q, ['reembols', 'me deve', 'devendo', 'a receber', 'dividi'])) {
      return Right(_sobreReembolsos(contexto, pessoa));
    }
    final cartao = contexto.cartoes.where((c) => q.contains(_normalizar(c.nome))).firstOrNull;
    if (cartao != null || _citaAlgum(q, ['fatura', 'cartao', 'cartoes', 'limite do cartao'])) {
      final mesCitado = _mesDeFaturaCitado(q, contexto);
      if (mesCitado != null) return Right(_sobreFaturaDoMes(mesCitado));
      if (_citaAlgum(q, ['proximo', 'proxima', 'mes que vem', 'por mes', 'meses'])) {
        return Right(_sobreFaturasPorMes(contexto));
      }
      return Right(_sobreCartoes(contexto, cartao));
    }
    if (_citaAlgum(q, ['invest', 'rendimento', 'aplicacao', 'aplicado', 'tesouro', 'cdb', 'poupanca'])) {
      return Right(_sobreInvestimentos(contexto));
    }
    if (_citaAlgum(q, ['parcela', 'parcelad'])) return Right(_sobreParcelas(contexto));
    if (_citaAlgum(q, ['conta a pagar', 'contas a pagar', 'contas', 'boleto', 'vence', 'vencer', 'atrasad'])) {
      return Right(_sobreContas(contexto));
    }
    if (_citaAlgum(q, ['mes passado', 'mes anterior', 'meses anteriores', 'comparad', 'evolu', 'historico'])) {
      return Right(_sobreHistorico(contexto, mes));
    }

    final categoria = _categoriaCitada(q, contexto);
    if (categoria != null) return Right(_sobreCategoria(categoria, contexto, mes));

    if (_citaAlgum(q, ['orcamento', 'limite', 'envelope'])) return Right(_sobreOrcamento(contexto));
    if (_citaAlgum(q, ['meta', 'reserva', 'objetivo'])) return Right(_sobreMetas(contexto));
    if (_citaAlgum(q, ['saldo', 'sobrou', 'sobra'])) return Right(_sobreSaldo(contexto, mes));

    return Right(_resumo(contexto, mes));
  }

  String? _categoriaCitada(String q, ContextoFinanceiro c) {
    final candidatas = {
      ...c.gastoPorCategoria.keys,
      ...c.envelopes.map((e) => e.categoria),
      ...kCategorias,
    };
    for (final categoria in candidatas) {
      if (q.contains(_normalizar(categoria))) return categoria;
    }
    return null;
  }

  String _sobreCategoria(String categoria, ContextoFinanceiro c, String mes) {
    final gasto = c.gastoPorCategoria[categoria] ?? 0;
    final envelope = c.envelopes.where((e) => e.categoria == categoria).firstOrNull;

    final base = gasto == 0
        ? 'Você ainda não tem gastos em $categoria em $mes.'
        : 'Em $categoria você gastou ${formatCurrency(gasto)} em $mes.';
    if (envelope == null) return base;

    final pct = (envelope.proporcao * 100).round();
    if (envelope.estourado) {
      return '$base Isso passou do limite de ${formatCurrency(envelope.limite)} '
          'em ${formatCurrency(-envelope.restante)} ($pct%).';
    }
    return '$base Isso é $pct% do limite de ${formatCurrency(envelope.limite)}; '
        'restam ${formatCurrency(envelope.restante)}.';
  }

  String _sobreOrcamento(ContextoFinanceiro c) {
    if (c.envelopes.isEmpty) {
      return 'Você ainda não definiu limites de orçamento. Crie um na tela de Orçamento '
          'para eu acompanhar por categoria.';
    }
    final gasto = c.envelopes.fold(0.0, (soma, e) => soma + e.gasto);
    final limite = c.envelopes.fold(0.0, (soma, e) => soma + e.limite);
    final estourados = c.envelopes.where((e) => e.estourado).map((e) => e.categoria).toList();
    final perto = c.envelopes.where((e) => !e.estourado && e.proporcao >= .9).map((e) => e.categoria).toList();

    final linhas = <String>[
      'Você gastou ${formatCurrency(gasto)} de ${formatCurrency(limite)} nos seus envelopes.',
      if (estourados.isNotEmpty) 'Estouraram: ${estourados.join(', ')}.',
      if (perto.isNotEmpty) 'Perto do limite: ${perto.join(', ')}.',
      if (estourados.isEmpty && perto.isEmpty) 'Todos os envelopes estão dentro do limite.',
    ];
    return linhas.join(' ');
  }

  String _sobreMetas(ContextoFinanceiro c) {
    if (c.metas.isEmpty) {
      return 'Você ainda não tem metas cadastradas. Crie uma na tela de Metas.';
    }
    return c.metas.map((m) {
      final base = '${m.nome}: ${m.percentual}% (${formatCurrency(m.valorAtual)} de ${formatCurrency(m.valorAlvo)})';
      final aporte = m.aporteMensalSugerido;
      return aporte > 0 ? '$base. Para chegar no prazo, guarde ${formatCurrency(aporte)} por mês.' : '$base.';
    }).join('\n');
  }

  String _sobreSaldo(ContextoFinanceiro c, String mes) {
    if (c.semMovimento) return 'Não há lançamentos em $mes ainda.';
    final sinal = c.saldo >= 0 ? 'sobrou' : 'faltou';
    return 'Em $mes entraram ${formatCurrency(c.receitas)} e saíram ${formatCurrency(c.despesas)}: '
        '$sinal ${formatCurrency(c.saldo.abs())}.';
  }

  String _resumo(ContextoFinanceiro c, String mes) {
    if (c.semMovimento) return 'Não há lançamentos em $mes ainda.';
    final maior = c.maiorCategoria;
    return [
      'Em $mes você recebeu ${formatCurrency(c.receitas)} e gastou ${formatCurrency(c.despesas)}.',
      if (maior != null) 'A maior despesa foi ${maior.key}, com ${formatCurrency(maior.value)}.',
    ].join(' ');
  }

  String _sobreReembolsos(ContextoFinanceiro c, String? pessoa) {
    if (c.reembolsos.isEmpty) return 'Ninguém te deve nada nas compras divididas.';
    if (pessoa != null) {
      return '$pessoa ainda te deve ${formatCurrency(c.reembolsos[pessoa] ?? 0)} pelas compras divididas.';
    }
    final lista = c.reembolsos.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final detalhe = lista.map((e) => '${e.key} (${formatCurrency(e.value)})').join(', ');
    return 'Você tem ${formatCurrency(c.totalAReceber)} a receber das compras divididas: $detalhe.';
  }

  String _sobreCartoes(ContextoFinanceiro c, CartaoResumoIa? cartao) {
    if (c.cartoes.isEmpty) return 'Você ainda não cadastrou cartões. Crie um na tela de Cartões.';
    String linha(CartaoResumoIa x) {
      if (x.faturaAberta <= 0) return '${x.nome}: sem fatura em aberto.';
      final venc = x.vencimento == null ? '' : ', vence em ${_dia(x.vencimento!)}${x.vencida ? ' (vencida)' : ''}';
      final limite = x.limite == null ? '' : ' (limite ${formatCurrency(x.limite!)})';
      return '${x.nome}: fatura em aberto de ${formatCurrency(x.faturaAberta)}$venc$limite.';
    }

    if (cartao != null) return linha(cartao);
    final total = c.totalFaturasAbertas;
    final linhas = c.cartoes.map(linha).join(' ');
    return total > 0 ? 'Faturas em aberto somam ${formatCurrency(total)}. $linhas' : 'Nenhuma fatura em aberto. $linhas';
  }

  MesDeFaturas? _mesDeFaturaCitado(String q, ContextoFinanceiro c) {
    for (final m in c.faturasPorMes) {
      if (q.contains(_normalizar(kMesesPorExtenso[m.mes - 1]))) return m;
    }
    return null;
  }

  String _sobreFaturaDoMes(MesDeFaturas m) {
    final nome = kMesesPorExtenso[m.mes - 1];
    final porCartao = m.faturas.map((f) => '${f.cartao.nome} (${formatCurrency(f.total)})').join(', ');
    return 'Em $nome de ${m.ano} vencem ${formatCurrency(m.total)} em faturas: $porCartao.';
  }

  String _sobreFaturasPorMes(ContextoFinanceiro c) {
    if (c.faturasPorMes.isEmpty) return 'Você não tem faturas em aberto nos próximos meses.';
    final linhas = c.faturasPorMes.take(6).map((m) => '${kMesesPorExtenso[m.mes - 1]}: ${formatCurrency(m.total)}').join('; ');
    final total = c.faturasPorMes.fold(0.0, (a, m) => a + m.total);
    return 'Suas faturas em aberto somam ${formatCurrency(total)}, por mês de vencimento: $linhas.';
  }

  String _sobreInvestimentos(ContextoFinanceiro c) {
    if (c.investimentos.isEmpty) return 'Você ainda não registrou investimentos. Cadastre na tela de Investimentos.';
    final resultado = c.totalInvestimentosAtual - c.totalInvestido;
    final sinal = resultado >= 0 ? 'ganho' : 'perda';
    final porTipo = <TipoInvestimento, double>{};
    for (final i in c.investimentos) {
      porTipo.update(i.tipo, (v) => v + i.valorAtual, ifAbsent: () => i.valorAtual);
    }
    final tipos = porTipo.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maior = tipos.first;
    return 'Você aplicou ${formatCurrency(c.totalInvestido)} e hoje tem ${formatCurrency(c.totalInvestimentosAtual)} '
        '($sinal de ${formatCurrency(resultado.abs())}). A maior parte está em ${maior.key.rotulo}, '
        'com ${formatCurrency(maior.value)}.';
  }

  String _sobreParcelas(ContextoFinanceiro c) {
    if (c.parcelasFuturas == 0) return 'Você não tem parcelas futuras de compras parceladas.';
    return 'Faltam ${c.parcelasFuturas} parcelas de compras parceladas, ${formatCurrency(c.valorParcelasFuturas)} no total.';
  }

  String _sobreContas(ContextoFinanceiro c) {
    if (c.contasAPagar.isEmpty) return 'Você não tem contas a pagar em aberto.';
    final hoje = c.hoje;
    final atrasadas = hoje == null ? <ContaAPagar>[] : c.contasAPagar.where((x) => x.statusEm(hoje) == StatusConta.atrasada).toList();
    final proximas = c.contasAPagar.take(3).map((x) => '${x.descricao} (${formatCurrency(x.valor)}, ${_dia(x.vencimento)})').join(', ');
    final total = c.contasAPagar.fold(0.0, (a, x) => a + x.valor);
    return [
      'Você tem ${c.contasAPagar.length} contas em aberto, somando ${formatCurrency(total)}.',
      if (atrasadas.isNotEmpty) '${atrasadas.length} atrasada(s).',
      'Próximas: $proximas.',
    ].join(' ');
  }

  String _sobreHistorico(ContextoFinanceiro c, String mes) {
    if (c.historico.isEmpty) return 'Ainda não tenho meses anteriores para comparar com $mes.';
    final anterior = c.historico.first;
    final nome = kMesesPorExtenso[anterior.mes.month - 1];
    final diferenca = c.despesas - anterior.despesas;
    final comparacao = diferenca == 0
        ? 'o mesmo valor'
        : '${formatCurrency(diferenca.abs())} ${diferenca > 0 ? 'a mais' : 'a menos'}';
    return 'Em $mes você gastou ${formatCurrency(c.despesas)}, $comparacao que em $nome (${formatCurrency(anterior.despesas)}). '
        'As receitas foram ${formatCurrency(c.receitas)} contra ${formatCurrency(anterior.receitas)}.';
  }

  String _dia(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  bool _citaAlgum(String q, List<String> termos) => termos.any(q.contains);

  String _normalizar(String texto) {
    const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const para = 'aaaaaeeeeiiiiooooouuuuc';
    final buffer = StringBuffer();
    for (final ch in texto.toLowerCase().split('')) {
      final i = de.indexOf(ch);
      buffer.write(i == -1 ? ch : para[i]);
    }
    return buffer.toString();
  }
}
