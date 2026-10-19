import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/ai_assistant/data/services/motor_resposta_por_regras.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/meta/domain/entities/meta.dart';

const _motor = MotorRespostaPorRegras();

ContextoFinanceiro _contexto({
  double receitas = 5000,
  double despesas = 1500,
  Map<String, double> porCategoria = const {'Mercado': 800, 'Lazer': 700},
  List<EnvelopeOrcamento> envelopes = const [],
  List<Meta> metas = const [],
}) =>
    ContextoFinanceiro(
      mes: DateTime(2026, 10, 15),
      receitas: receitas,
      despesas: despesas,
      gastoPorCategoria: porCategoria,
      envelopes: envelopes,
      metas: metas,
    );

Future<String> _responder(String pergunta, ContextoFinanceiro contexto) async {
  final r = await _motor.responder(pergunta: pergunta, contexto: contexto);
  return r.getOrElse((_) => throw StateError('esperava Right'));
}

void main() {
  test('resumo traz receitas, despesas e a maior categoria', () async {
    final texto = await _responder('Resumo do mês', _contexto());

    expect(texto, contains('R\$ 5.000,00'));
    expect(texto, contains('R\$ 1.500,00'));
    expect(texto, contains('Mercado'));
    expect(texto, contains('outubro'));
  });

  test('sem movimento no mês avisa em vez de inventar números', () async {
    final texto = await _responder(
      'Resumo do mês',
      _contexto(receitas: 0, despesas: 0, porCategoria: const {}),
    );

    expect(texto, contains('Não há lançamentos'));
  });

  test('pergunta por categoria usa o gasto dela, ignorando acento e caixa', () async {
    final texto = await _responder('quanto gastei com MERCADO?', _contexto());

    expect(texto, contains('R\$ 800,00'));
  });

  test('categoria com limite mostra a porcentagem e o que resta', () async {
    const envelope = EnvelopeOrcamento(
      orcamento: Orcamento(id: 'o', categoria: 'Mercado', limite: 1000),
      gasto: 800,
    );

    final texto = await _responder('Gastos com mercado', _contexto(envelopes: const [envelope]));

    expect(texto, contains('80%'));
    expect(texto, contains('R\$ 200,00'));
  });

  test('categoria estourada informa quanto passou', () async {
    const envelope = EnvelopeOrcamento(
      orcamento: Orcamento(id: 'o', categoria: 'Mercado', limite: 500),
      gasto: 800,
    );

    final texto = await _responder('mercado', _contexto(envelopes: const [envelope]));

    expect(texto, contains('passou do limite'));
    expect(texto, contains('R\$ 300,00'));
  });

  test('orçamento lista os envelopes estourados e os perto do limite', () async {
    final envelopes = [
      const EnvelopeOrcamento(orcamento: Orcamento(id: '1', categoria: 'Mercado', limite: 500), gasto: 600),
      const EnvelopeOrcamento(orcamento: Orcamento(id: '2', categoria: 'Lazer', limite: 100), gasto: 95),
      const EnvelopeOrcamento(orcamento: Orcamento(id: '3', categoria: 'Transporte', limite: 400), gasto: 50),
    ];

    final texto = await _responder('Como estou no orçamento?', _contexto(envelopes: envelopes));

    expect(texto, contains('Estouraram: Mercado'));
    expect(texto, contains('Perto do limite: Lazer'));
    expect(texto, isNot(contains('Transporte')));
  });

  test('orçamento sem limites orienta a criar um', () async {
    final texto = await _responder('orçamento', _contexto());

    expect(texto, contains('ainda não definiu limites'));
  });

  test('metas mostram progresso e aporte sugerido', () async {
    final meta = Meta(
      id: 'm',
      nome: 'Reserva',
      valorAtual: 5000,
      valorAlvo: 10000,
      prazo: DateTime(DateTime.now().year + 1, DateTime.now().month, 1),
    );

    final texto = await _responder('Como está minha reserva?', _contexto(metas: [meta]));

    expect(texto, contains('Reserva: 50%'));
    expect(texto, contains('por mês'));
  });

  test('sem metas orienta a criar uma', () async {
    final texto = await _responder('minha meta', _contexto());

    expect(texto, contains('ainda não tem metas'));
  });

  test('saldo positivo diz que sobrou, negativo diz que faltou', () async {
    expect(await _responder('quanto sobrou?', _contexto()), contains('sobrou R\$ 3.500,00'));
    expect(
      await _responder('saldo', _contexto(receitas: 1000, despesas: 1500)),
      contains('faltou R\$ 500,00'),
    );
  });
}
