import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/utils/date_label.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';
import 'package:teofinance/features/ai_assistant/domain/services/motor_resposta.dart';

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
