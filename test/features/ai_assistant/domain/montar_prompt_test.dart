import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';
import 'package:teofinance/features/ai_assistant/domain/services/montar_prompt.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/meta/domain/entities/meta.dart';

ContextoFinanceiro _contexto({
  Map<String, double> porCategoria = const {'Mercado': 800, 'Lazer': 700},
  List<EnvelopeOrcamento> envelopes = const [],
  List<Meta> metas = const [],
}) =>
    ContextoFinanceiro(
      mes: DateTime(2026, 10, 15),
      receitas: 5000,
      despesas: 1500,
      gastoPorCategoria: porCategoria,
      envelopes: envelopes,
      metas: metas,
    );

void main() {
  test('traz o mês, os totais e a pergunta no formato brasileiro', () {
    final p = montarPrompt(pergunta: 'Quanto gastei?', contexto: _contexto());

    expect(p.mensagem, contains('Resumo de outubro de 2026'));
    expect(p.mensagem, contains('Receitas: R\$ 5.000,00'));
    expect(p.mensagem, contains('Despesas: R\$ 1.500,00'));
    expect(p.mensagem, contains('Saldo: R\$ 3.500,00'));
    expect(p.mensagem, endsWith('Pergunta do usuário: Quanto gastei?'));
  });

  test('as instruções obrigam a responder só com os dados e em português', () {
    final p = montarPrompt(pergunta: 'oi', contexto: _contexto());

    expect(p.instrucoes, contains('português do Brasil'));
    expect(p.instrucoes, contains('SOMENTE os dados'));
    expect(p.instrucoes, contains('Nunca invente'));
  });

  test('categorias saem da maior para a menor', () {
    final p = montarPrompt(pergunta: 'x', contexto: _contexto());

    expect(p.mensagem.indexOf('Mercado'), lessThan(p.mensagem.indexOf('Lazer')));
  });

  test('limita categorias, envelopes e metas para caber no contexto do modelo', () {
    final categorias = {for (var i = 0; i < 30; i++) 'Cat$i': 100.0 + i};
    final envelopes = [
      for (var i = 0; i < 30; i++)
        EnvelopeOrcamento(orcamento: Orcamento(id: '$i', categoria: 'Env$i', limite: 100), gasto: 10),
    ];
    final metas = [
      for (var i = 0; i < 30; i++)
        Meta(id: '$i', nome: 'Meta$i', valorAtual: 1, valorAlvo: 10, prazo: DateTime(2027)),
    ];

    final p = montarPrompt(
      pergunta: 'x',
      contexto: _contexto(porCategoria: categorias, envelopes: envelopes, metas: metas),
    );

    expect(RegExp(r'- Cat\d+:').allMatches(p.mensagem), hasLength(8));
    expect(RegExp(r'- Env\d+:').allMatches(p.mensagem), hasLength(10));
    expect(RegExp(r'- Meta\d+:').allMatches(p.mensagem), hasLength(5));
    expect(p.mensagem, contains('Cat29'));
    expect(p.mensagem, isNot(contains('Cat0:')));
  });

  test('envelope estourado é sinalizado', () {
    const envelope = EnvelopeOrcamento(
      orcamento: Orcamento(id: 'o', categoria: 'Mercado', limite: 500),
      gasto: 800,
    );

    final p = montarPrompt(pergunta: 'x', contexto: _contexto(envelopes: const [envelope]));

    expect(p.mensagem, contains('Mercado: R\$ 800,00 de R\$ 500,00 (estourado)'));
  });

  test('seções sem dados não aparecem', () {
    final p = montarPrompt(pergunta: 'x', contexto: _contexto(porCategoria: const {}));

    expect(p.mensagem, isNot(contains('Maiores gastos')));
    expect(p.mensagem, isNot(contains('Orçamento por categoria')));
    expect(p.mensagem, isNot(contains('Metas:')));
  });

  test('pergunta enorme é cortada em 300 caracteres', () {
    final p = montarPrompt(pergunta: 'a' * 5000, contexto: _contexto());

    expect(p.mensagem.split('Pergunta do usuário: ').last.length, 300);
  });

  test('o tamanho do prompt não cresce sem limite mesmo com muitos dados', () {
    final categorias = {for (var i = 0; i < 500; i++) 'Categoria longa número $i': 100.0 + i};

    final p = montarPrompt(pergunta: 'x', contexto: _contexto(porCategoria: categorias));

    expect(p.mensagem.length + p.instrucoes.length, lessThan(2000));
  });
}
