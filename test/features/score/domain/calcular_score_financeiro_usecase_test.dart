import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/repositories/orcamento_repository.dart';
import 'package:teofinance/features/meta/domain/entities/meta.dart';
import 'package:teofinance/features/meta/domain/repositories/meta_repository.dart';
import 'package:teofinance/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:teofinance/features/score/domain/entities/score_financeiro.dart';
import 'package:teofinance/features/score/domain/usecases/calcular_score_financeiro_usecase.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';

class _Transacoes implements TransacaoRepository {
  _Transacoes(this.dados);
  final List<Transacao> dados;

  @override
  Stream<List<Transacao>> observarTodas() => Stream.value(dados);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Orcamentos implements OrcamentoRepository {
  _Orcamentos(this.dados);
  final List<Orcamento> dados;

  @override
  Stream<List<Orcamento>> observarTodos() => Stream.value(dados);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Metas implements MetaRepository {
  _Metas(this.dados);
  final List<Meta> dados;

  @override
  Stream<List<Meta>> observarTodas() => Stream.value(dados);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Reconciliacao implements ReconciliationRepository {
  _Reconciliacao({this.linhas = 0, this.conferidas = 0, this.falha = false});
  final int linhas;
  final int conferidas;
  final bool falha;
  DateTime? inicioPedido;
  DateTime? fimPedido;

  @override
  Future<Either<Failure, ReconciliationStatus>> obterStatusPeriodo({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    inicioPedido = dataInicio;
    fimPedido = dataFim;
    if (falha) return const Left(CacheFailure('x'));
    return Right(ReconciliationStatus(
      totalTransacoes: 0,
      totalLinhasExtrato: linhas,
      matched: conferidas,
      orphans: linhas - conferidas,
      unmatched: 0,
      percentualReconciliado: 0,
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _agora = DateTime(2026, 10, 19);

Transacao _t(double valor, {DateTime? data, String categoria = 'Mercado', double? minhaParte}) => Transacao(
      id: '$valor${data ?? ''}$categoria',
      descricao: 'x',
      categoria: categoria,
      valor: valor,
      data: data ?? DateTime(2026, 10, 5),
      minhaParte: minhaParte,
    );

CalcularScoreFinanceiroUseCase _criar({
  List<Transacao> transacoes = const [],
  List<Orcamento> limites = const [],
  List<Meta> metas = const [],
  _Reconciliacao? reconciliacao,
}) =>
    CalcularScoreFinanceiroUseCase(
      transacoes: _Transacoes(transacoes),
      orcamentos: _Orcamentos(limites),
      metas: _Metas(metas),
      reconciliacao: reconciliacao ?? _Reconciliacao(),
      agora: () => _agora,
    );

Future<ScoreFinanceiro> _calcular(CalcularScoreFinanceiroUseCase u) async =>
    (await u()).getOrElse((f) => throw StateError(f.message));

ComponenteScore _c(ScoreFinanceiro s, String nome) => s.componentes.firstWhere((c) => c.nome == nome);

void main() {
  test('sem nenhum dado, não há nota', () async {
    final s = await _calcular(_criar());

    expect(s.pontos, isNull);
  });

  test('receitas e despesas contam só o mês corrente', () async {
    final s = await _calcular(_criar(transacoes: [
      _t(1000, categoria: 'Renda'),
      _t(-500),
      _t(-9999, data: DateTime(2026, 9, 30)),
      _t(5000, data: DateTime(2026, 11, 1), categoria: 'Renda'),
    ]));

    expect(_c(s, 'Poupança do mês').fracao, 1); // guardou 50%
  });

  test('compra dividida pesa só a parte do usuário', () async {
    final s = await _calcular(_criar(transacoes: [
      _t(1000, categoria: 'Renda'),
      _t(-1000, minhaParte: 100),
    ]));

    expect(_c(s, 'Poupança do mês').detalhe, contains('90%'));
  });

  test('envelopes usam o gasto real do mês', () async {
    final s = await _calcular(_criar(
      transacoes: [_t(-150)],
      limites: const [Orcamento(id: 'o', categoria: 'Mercado', limite: 100)],
    ));

    expect(_c(s, 'Orçamento').fracao, 0); // estourou
  });

  test('metas entram pela média de progresso', () async {
    final s = await _calcular(_criar(
      metas: [Meta(id: 'm', nome: 'Reserva', valorAtual: 25, valorAlvo: 100, prazo: DateTime(2030))],
    ));

    expect(_c(s, 'Metas').fracao, closeTo(0.25, 1e-9));
  });

  test('reconciliação do mês entra com linhas e conferidas, pedindo o mês inteiro', () async {
    final rec = _Reconciliacao(linhas: 8, conferidas: 6);

    final s = await _calcular(_criar(reconciliacao: rec));

    expect(_c(s, 'Extrato conferido').fracao, closeTo(0.75, 1e-9));
    expect(rec.inicioPedido, DateTime(2026, 10));
    expect(rec.fimPedido!.month, 10);
    expect(rec.fimPedido!.day, 31);
  });

  test('falha ao ler a reconciliação deixa só esse componente sem dado', () async {
    final s = await _calcular(_criar(
      transacoes: [_t(1000, categoria: 'Renda'), _t(-500)],
      reconciliacao: _Reconciliacao(falha: true),
    ));

    expect(_c(s, 'Extrato conferido').disponivel, isFalse);
    expect(s.pontos, 1000);
  });

  test('erro ao ler os repositórios vira falha, nunca exceção', () async {
    final usecase = CalcularScoreFinanceiroUseCase(
      transacoes: _TransacoesQuebrado(),
      orcamentos: _Orcamentos(const []),
      metas: _Metas(const []),
      reconciliacao: _Reconciliacao(),
      agora: () => _agora,
    );

    final r = await usecase();

    expect(r.swap().getOrElse((_) => throw StateError('esperava Left')), isA<CacheFailure>());
  });
}

class _TransacoesQuebrado implements TransacaoRepository {
  @override
  Stream<List<Transacao>> observarTodas() => Stream.error(StateError('quebrou'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
