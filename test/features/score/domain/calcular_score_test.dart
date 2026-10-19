import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/meta/domain/entities/meta.dart';
import 'package:teofinance/features/score/domain/entities/score_financeiro.dart';
import 'package:teofinance/features/score/domain/services/calcular_score.dart';

const _semOrcamento = ResumoOrcamento([]);

EnvelopeOrcamento _envelope(double gasto, {double limite = 100, String categoria = 'Mercado'}) =>
    EnvelopeOrcamento(orcamento: Orcamento(id: categoria, categoria: categoria, limite: limite), gasto: gasto);

Meta _meta(double atual, double alvo) =>
    Meta(id: '$atual$alvo', nome: 'm', valorAtual: atual, valorAlvo: alvo, prazo: DateTime(2030));

ComponenteScore _componente(ScoreFinanceiro s, String nome) => s.componentes.firstWhere((c) => c.nome == nome);

ScoreFinanceiro _calcular({
  double receitas = 0,
  double despesas = 0,
  ResumoOrcamento orcamento = _semOrcamento,
  List<Meta> metas = const [],
  int? linhas,
  int? conferidas,
}) =>
    calcularScore(
      receitas: receitas,
      despesas: despesas,
      orcamento: orcamento,
      metas: metas,
      linhasExtrato: linhas,
      linhasConferidas: conferidas,
    );

void main() {
  group('sem dados', () {
    test('nenhum componente disponível não inventa nota nem faixa', () {
      final s = _calcular();

      expect(s.pontos, isNull);
      expect(s.faixa, isNull);
      expect(s.componentes.every((c) => !c.disponivel), isTrue);
    });

    test('os pesos dos quatro componentes somam 100', () {
      expect(_calcular().componentes.fold<int>(0, (soma, c) => soma + c.peso), 100);
    });
  });

  group('poupança do mês', () {
    test('guardar 20% da renda ou mais vale nota cheia', () {
      expect(_componente(_calcular(receitas: 1000, despesas: 800), 'Poupança do mês').fracao, 1);
      expect(_componente(_calcular(receitas: 1000, despesas: 300), 'Poupança do mês').fracao, 1);
    });

    test('guardar 10% vale metade', () {
      expect(_componente(_calcular(receitas: 1000, despesas: 900), 'Poupança do mês').fracao, closeTo(0.5, 1e-9));
    });

    test('gastar mais do que recebeu vale zero e o detalhe diz isso', () {
      final c = _componente(_calcular(receitas: 1000, despesas: 1200), 'Poupança do mês');

      expect(c.fracao, 0);
      expect(c.detalhe, contains('gastou mais do que recebeu'));
    });

    test('gasto sem nenhuma receita vale zero', () {
      final c = _componente(_calcular(despesas: 300), 'Poupança do mês');

      expect(c.fracao, 0);
      expect(c.detalhe, contains('nenhuma receita'));
    });

    test('detalhe mostra a porcentagem guardada', () {
      expect(_componente(_calcular(receitas: 1000, despesas: 850), 'Poupança do mês').detalhe, contains('15%'));
    });
  });

  group('orçamento', () {
    test('conta a fração de envelopes dentro do limite', () {
      final s = _calcular(
        orcamento: ResumoOrcamento([_envelope(50, categoria: 'A'), _envelope(150, categoria: 'B'), _envelope(100, categoria: 'C')]),
      );

      final c = _componente(s, 'Orçamento');
      expect(c.fracao, closeTo(2 / 3, 1e-9));
      expect(c.detalhe, '2 de 3 envelopes dentro do limite.');
    });

    test('gastar exatamente o limite ainda está dentro', () {
      final s = _calcular(orcamento: ResumoOrcamento([_envelope(100)]));

      expect(_componente(s, 'Orçamento').fracao, 1);
    });
  });

  group('metas', () {
    test('usa a média do progresso das metas', () {
      final s = _calcular(metas: [_meta(50, 100), _meta(100, 100)]);

      expect(_componente(s, 'Metas').fracao, closeTo(0.75, 1e-9));
    });

    test('meta além do alvo não passa de 100%', () {
      expect(_componente(_calcular(metas: [_meta(500, 100)]), 'Metas').fracao, 1);
    });
  });

  group('extrato conferido', () {
    test('fração das linhas conferidas', () {
      final c = _componente(_calcular(linhas: 10, conferidas: 4), 'Extrato conferido');

      expect(c.fracao, closeTo(0.4, 1e-9));
      expect(c.detalhe, '4 de 10 linhas do extrato conferidas.');
    });

    test('sem extrato ou com zero linhas o componente fica sem dado', () {
      expect(_componente(_calcular(), 'Extrato conferido').disponivel, isFalse);
      expect(_componente(_calcular(linhas: 0, conferidas: 0), 'Extrato conferido').disponivel, isFalse);
    });

    test('conferidas acima do total não passam de 100%', () {
      expect(_componente(_calcular(linhas: 5, conferidas: 9), 'Extrato conferido').fracao, 1);
    });
  });

  group('nota final', () {
    test('tudo perfeito dá 1000', () {
      final s = _calcular(
        receitas: 1000,
        despesas: 500,
        orcamento: ResumoOrcamento([_envelope(10)]),
        metas: [_meta(100, 100)],
        linhas: 4,
        conferidas: 4,
      );

      expect(s.pontos, 1000);
      expect(s.faixa, FaixaScore.excelente);
    });

    test('tudo no pior caso dá 0', () {
      final s = _calcular(
        receitas: 1000,
        despesas: 2000,
        orcamento: ResumoOrcamento([_envelope(500)]),
        metas: [_meta(0, 100)],
        linhas: 4,
        conferidas: 0,
      );

      expect(s.pontos, 0);
      expect(s.faixa, FaixaScore.atencao);
    });

    test('componentes sem dado saem da conta e os pesos se redistribuem', () {
      // Só poupança (peso 30) com nota cheia: vale 1000, não 300.
      expect(_calcular(receitas: 1000, despesas: 500).pontos, 1000);
    });

    test('média ponderada: poupança cheia (30) e metas a 50% (20) dão 800', () {
      final s = _calcular(receitas: 1000, despesas: 500, metas: [_meta(50, 100)]);

      expect(s.pontos, 800); // (30*1 + 20*0.5) / 50 * 1000
    });

    test('um componente sem dado não puxa a nota para baixo', () {
      final comMetas = _calcular(receitas: 1000, despesas: 500, metas: [_meta(100, 100)]);
      final semMetas = _calcular(receitas: 1000, despesas: 500);

      expect(comMetas.pontos, semMetas.pontos);
    });
  });

  group('faixas', () {
    ScoreFinanceiro comNota(int pontos) => ScoreFinanceiro([
          ComponenteScore(nome: 'x', peso: 100, fracao: pontos / 1000, detalhe: ''),
        ]);

    test('limites exatos entre as faixas', () {
      expect(comNota(0).faixa, FaixaScore.atencao);
      expect(comNota(399).faixa, FaixaScore.atencao);
      expect(comNota(400).faixa, FaixaScore.regular);
      expect(comNota(599).faixa, FaixaScore.regular);
      expect(comNota(600).faixa, FaixaScore.bom);
      expect(comNota(799).faixa, FaixaScore.bom);
      expect(comNota(800).faixa, FaixaScore.excelente);
      expect(comNota(1000).faixa, FaixaScore.excelente);
    });

    test('cada faixa tem rótulo em português', () {
      expect(FaixaScore.values.map((f) => f.rotulo), ['Atenção', 'Regular', 'Bom', 'Excelente']);
    });
  });
}
