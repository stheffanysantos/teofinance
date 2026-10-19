import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/utils/date_label.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';

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
const _maxCaracteresPergunta = 300;

const _instrucoes =
    'Você é o assistente financeiro do TeoFinance. Responda em português do Brasil, '
    'em no máximo 3 frases curtas. Use SOMENTE os dados do resumo fornecido; se a '
    'resposta não estiver neles, diga que não tem essa informação. Nunca invente '
    'valores, não dê recomendação de investimento e não peça dados pessoais.';

/// Monta o prompt só com o agregado do mês — nunca a lista de transações —, com
/// tamanho limitado, porque o contexto do modelo no aparelho é pequeno e
/// `.claude/agents/ai-assistant-engineer.md` proíbe mandar mais dado que o
/// necessário.
PromptAssistente montarPrompt({
  required String pergunta,
  required ContextoFinanceiro contexto,
}) {
  final b = StringBuffer()
    ..writeln('Resumo de ${kMesesPorExtenso[contexto.mes.month - 1]} de ${contexto.mes.year}:')
    ..writeln('- Receitas: ${formatCurrency(contexto.receitas)}')
    ..writeln('- Despesas: ${formatCurrency(contexto.despesas)}')
    ..writeln('- Saldo: ${formatCurrency(contexto.saldo)}');

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
