import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/meta/domain/entities/meta.dart';
import 'package:teofinance/features/score/domain/entities/score_financeiro.dart';

/// Taxa de poupança que vale nota cheia: guardar 20% da renda do mês.
const kTaxaDePoupancaIdeal = 0.2;

int _percentual(double fracao) => (fracao * 100).round();

/// Calcula o score do mês a partir de dados já agregados. Função pura: toda a
/// regra da nota mora aqui e é coberta por teste.
///
/// [linhasExtrato] e [linhasConferidas] vêm da reconciliação do mês; nulos (ou
/// zero linhas) significam que não há extrato importado.
ScoreFinanceiro calcularScore({
  required double receitas,
  required double despesas,
  required ResumoOrcamento orcamento,
  required List<Meta> metas,
  int? linhasExtrato,
  int? linhasConferidas,
}) {
  return ScoreFinanceiro([
    _orcamento(orcamento),
    _poupanca(receitas, despesas),
    _metas(metas),
    _reconciliacao(linhasExtrato, linhasConferidas),
  ]);
}

ComponenteScore _orcamento(ResumoOrcamento resumo) {
  const nome = 'Orçamento';
  if (resumo.envelopes.isEmpty) {
    return const ComponenteScore(
      nome: nome,
      peso: 30,
      fracao: null,
      detalhe: 'Defina limites por categoria para medir.',
    );
  }

  final total = resumo.envelopes.length;
  final dentro = resumo.envelopes.where((e) => !e.estourado).length;
  return ComponenteScore(
    nome: nome,
    peso: 30,
    fracao: dentro / total,
    detalhe: '$dentro de $total envelopes dentro do limite.',
  );
}

ComponenteScore _poupanca(double receitas, double despesas) {
  const nome = 'Poupança do mês';
  if (receitas <= 0 && despesas <= 0) {
    return const ComponenteScore(
      nome: nome,
      peso: 30,
      fracao: null,
      detalhe: 'Sem lançamentos neste mês.',
    );
  }
  if (receitas <= 0) {
    return const ComponenteScore(
      nome: nome,
      peso: 30,
      fracao: 0,
      detalhe: 'Há gastos e nenhuma receita registrada.',
    );
  }

  final taxa = (receitas - despesas) / receitas;
  final fracao = (taxa / kTaxaDePoupancaIdeal).clamp(0.0, 1.0);
  final meta = _percentual(kTaxaDePoupancaIdeal);
  return ComponenteScore(
    nome: nome,
    peso: 30,
    fracao: fracao,
    detalhe: taxa < 0
        ? 'Você gastou mais do que recebeu.'
        : 'Você guardou ${_percentual(taxa)}% da renda (nota cheia a partir de $meta%).',
  );
}

ComponenteScore _metas(List<Meta> metas) {
  const nome = 'Metas';
  if (metas.isEmpty) {
    return const ComponenteScore(
      nome: nome,
      peso: 20,
      fracao: null,
      detalhe: 'Crie uma meta para medir.',
    );
  }

  final media = metas.fold<double>(0, (soma, m) => soma + m.progresso) / metas.length;
  return ComponenteScore(
    nome: nome,
    peso: 20,
    fracao: media,
    detalhe: 'Progresso médio das metas: ${_percentual(media)}%.',
  );
}

ComponenteScore _reconciliacao(int? linhasExtrato, int? linhasConferidas) {
  const nome = 'Extrato conferido';
  if (linhasExtrato == null || linhasExtrato <= 0) {
    return const ComponenteScore(
      nome: nome,
      peso: 20,
      fracao: null,
      detalhe: 'Importe um extrato do mês para medir.',
    );
  }

  final conferidas = (linhasConferidas ?? 0).clamp(0, linhasExtrato);
  return ComponenteScore(
    nome: nome,
    peso: 20,
    fracao: conferidas / linhasExtrato,
    detalhe: '$conferidas de $linhasExtrato linhas do extrato conferidas.',
  );
}
