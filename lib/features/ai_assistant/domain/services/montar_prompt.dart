import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/utils/date_label.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';

/// Texto entregue ao modelo, em duas partes.
class PromptAssistente {
  const PromptAssistente({required this.instrucoes, required this.mensagem});

  /// Papel e regras de resposta (a "instrução de sistema").
  final String instrucoes;

  /// Resumo do mês + pergunta do usuário.
  final String mensagem;
}

const _maxCategorias = 8;
const _maxEnvelopes = 10;
const _maxMetas = 5;
const _maxCartoes = 4;
const _maxReembolsos = 5;
const _maxContas = 6;
const _maxTiposInvestimento = 6;
const _maxCaracteresPergunta = 300;

const _instrucoes =
    'Você é o assistente financeiro do TeoFinance e só fala sobre as finanças do '
    'usuário neste app (gastos, receitas, saldo, orçamento, metas, cartões e '
    'faturas, contas a pagar, reembolsos e investimentos). Responda em '
    'português do Brasil, em no máximo 3 frases curtas. Use SOMENTE os dados do '
    'resumo fornecido; se a resposta não estiver neles, diga que não tem essa '
    'informação. Copie os valores do resumo exatamente como estão, sem refazer '
    'contas. Se a pergunta não for sobre as finanças do usuário, responda apenas: '
    '"Só posso ajudar com as suas finanças no TeoFinance." Nunca invente valores, '
    'não dê recomendação de investimento e não peça dados pessoais.\n'
    'Exemplos do formato (os valores abaixo são só de exemplo; use sempre os do resumo):\n'
    'Pergunta: Quanto minha mãe me deve?\n'
    'Resposta: Sua mãe ainda deve R\$ 120,00 pelas compras divididas.\n'
    'Pergunta: Quando vence a fatura do Nubank?\n'
    'Resposta: A fatura do Nubank está em R\$ 300,00 e vence em 05/12.\n'
    'Pergunta: Gastei mais ou menos que mês passado?\n'
    'Resposta: Você gastou R\$ 2.000,00 este mês, R\$ 150,00 a menos que no mês passado.';

/// Monta o prompt só com agregados — nunca a lista de transações —, com
/// tamanho limitado, porque o contexto do modelo no aparelho é pequeno e
/// `.claude/agents/ai-assistant-engineer.md` proíbe mandar mais dado que o
/// necessário. Seções sem dados nem aparecem.
PromptAssistente montarPrompt({
  required String pergunta,
  required ContextoFinanceiro contexto,
}) {
  final b = StringBuffer();
  final hoje = contexto.hoje;
  if (hoje != null) b.writeln('Hoje é ${_data(hoje, comAno: true)}.');
  b
    ..writeln('Resumo de ${kMesesPorExtenso[contexto.mes.month - 1]} de ${contexto.mes.year}:')
    ..writeln('- Receitas: ${formatCurrency(contexto.receitas)}')
    ..writeln('- Despesas: ${formatCurrency(contexto.despesas)}')
    ..writeln('- Saldo: ${formatCurrency(contexto.saldo)}');

  if (contexto.historico.isNotEmpty) {
    b.writeln('Meses anteriores (receitas, despesas):');
    for (final m in contexto.historico) {
      b.writeln(
        '- ${kMesesPorExtenso[m.mes.month - 1]}: ${formatCurrency(m.receitas)}, ${formatCurrency(m.despesas)}',
      );
    }
  }

  final categorias = contexto.gastoPorCategoria.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  if (categorias.isNotEmpty) {
    b.writeln('Maiores gastos por categoria:');
    for (final c in categorias.take(_maxCategorias)) {
      b.writeln('- ${c.key}: ${formatCurrency(c.value)}');
    }
  }

  if (contexto.envelopes.isNotEmpty) {
    b.writeln('Orçamento por categoria (gasto de limite):');
    for (final e in contexto.envelopes.take(_maxEnvelopes)) {
      final situacao = e.estourado ? ' (estourado)' : '';
      b.writeln('- ${e.categoria}: ${formatCurrency(e.gasto)} de ${formatCurrency(e.limite)}$situacao');
    }
  }

  if (contexto.cartoes.isNotEmpty) {
    b.writeln('Cartões (fatura em aberto):');
    for (final c in contexto.cartoes.take(_maxCartoes)) {
      final venc = c.vencimento == null ? '' : ', vence em ${_data(c.vencimento!)}${c.vencida ? ' (vencida)' : ''}';
      final limite = c.limite == null ? '' : ', limite ${formatCurrency(c.limite!)}';
      b.writeln('- ${c.nome}: ${formatCurrency(c.faturaAberta)}$venc$limite');
    }
  }

  if (contexto.parcelasFuturas > 0) {
    b.writeln(
      'Parcelas futuras de compras parceladas: ${contexto.parcelasFuturas} '
      '(${formatCurrency(contexto.valorParcelasFuturas)} no total).',
    );
  }

  if (contexto.reembolsos.isNotEmpty) {
    final pessoas = contexto.reembolsos.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    b.writeln('Reembolsos a receber (total ${formatCurrency(contexto.totalAReceber)}):');
    for (final p in pessoas.take(_maxReembolsos)) {
      b.writeln('- ${p.key}: ${formatCurrency(p.value)}');
    }
  }

  if (contexto.contasAPagar.isNotEmpty) {
    b.writeln('Contas a pagar em aberto:');
    for (final c in contexto.contasAPagar.take(_maxContas)) {
      final status = switch (hoje == null ? StatusConta.aVencer : c.statusEm(hoje)) {
        StatusConta.atrasada => ' (atrasada)',
        StatusConta.venceHoje => ' (vence hoje)',
        _ => '',
      };
      b.writeln('- ${c.descricao}: ${formatCurrency(c.valor)}, vence em ${_data(c.vencimento)}$status');
    }
  }

  if (contexto.investimentos.isNotEmpty) {
    final porTipo = <TipoInvestimento, double>{};
    for (final i in contexto.investimentos) {
      porTipo.update(i.tipo, (v) => v + i.valorAtual, ifAbsent: () => i.valorAtual);
    }
    final tipos = porTipo.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    b.writeln(
      'Investimentos: aplicado ${formatCurrency(contexto.totalInvestido)}, '
      'valor atual ${formatCurrency(contexto.totalInvestimentosAtual)}.',
    );
    for (final t in tipos.take(_maxTiposInvestimento)) {
      b.writeln('- ${t.key.rotulo}: ${formatCurrency(t.value)}');
    }
  }

  if (contexto.metas.isNotEmpty) {
    b.writeln('Metas:');
    for (final m in contexto.metas.take(_maxMetas)) {
      b.writeln('- ${m.nome}: ${m.percentual}% (${formatCurrency(m.valorAtual)} de ${formatCurrency(m.valorAlvo)})');
    }
  }

  final texto = pergunta.trim();
  final recortada = texto.length > _maxCaracteresPergunta ? texto.substring(0, _maxCaracteresPergunta) : texto;
  b
    ..writeln()
    ..write('Pergunta do usuário: $recortada');

  return PromptAssistente(instrucoes: _instrucoes, mensagem: b.toString());
}

String _data(DateTime d, {bool comAno = false}) {
  final dia = d.day.toString().padLeft(2, '0');
  final mes = d.month.toString().padLeft(2, '0');
  return comAno ? '$dia/$mes/${d.year}' : '$dia/$mes';
}
