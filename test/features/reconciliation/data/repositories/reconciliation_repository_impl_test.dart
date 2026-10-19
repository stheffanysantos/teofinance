import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/reconciliation/data/datasources/reconciliation_local_data_source.dart';
import 'package:teofinance/features/reconciliation/data/repositories/reconciliation_repository_impl.dart';
import 'package:teofinance/features/reconciliation/data/services/transacao_matcher_service.dart';
import 'package:teofinance/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';

void main() {
  late AppDatabase db;
  late TransacaoLocalDataSource transacoes;
  late ReconciliationRepositoryImpl repository;

  final dia = DateTime(2026, 10, 10);
  final inicio = DateTime(2026, 10, 1);
  final fim = DateTime(2026, 10, 31, 23, 59);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    transacoes = TransacaoLocalDataSource(db);
    repository = ReconciliationRepositoryImpl(
      ReconciliationLocalDataSourceImpl(db),
      transacoes,
      TransacaoMatcherService(),
    );
  });

  tearDown(() => db.close());

  Future<void> linha(double valor, DateTime data, {String tipo = 'D'}) async {
    await repository.importarExtrato(
      importId: 'imp',
      linhas: [
        {'descricao': 'banco', 'valor': valor, 'data': data.toIso8601String(), 'tipo': tipo, 'nomeBancoOriginal': 'b'},
      ],
    );
  }

  Future<ReconciliationResultado> reconciliar() async {
    final r = await repository.fazerMatching(userId: 'u', dataInicio: inicio, dataFim: fim);
    return r.getOrElse((f) => throw StateError(f.message));
  }

  test('valor e data iguais viram match automático e não geram órfã', () async {
    await transacoes.criar(descricao: 'Café', valor: -50, data: dia, categoria: 'x');
    await linha(50, dia);

    final r = await reconciliar();

    expect(r.matches.map((m) => m.status), ['auto_matched']);
  });

  test('linha sem transação vira órfã', () async {
    await linha(80, dia);

    final r = await reconciliar();

    expect(r.matches.map((m) => m.status), ['orphan']);
    expect(r.matches.single.transacaoId, isNull);
  });

  test('rodar de novo não duplica os matches', () async {
    await transacoes.criar(descricao: 'Café', valor: -50, data: dia, categoria: 'x');
    await linha(50, dia);
    await linha(80, dia);

    await reconciliar();
    final r = await reconciliar();

    expect(r.matches, hasLength(2));
  });

  test('aprovação manual sobrevive a uma nova execução', () async {
    await transacoes.criar(descricao: 'Café', valor: -50, data: dia, categoria: 'x');
    await linha(50, dia.add(const Duration(days: 2)));
    final candidato = (await reconciliar()).matches.single;
    expect(candidato.status, 'unmatched');

    await repository.aprovarMatch(candidato.id);
    final r = await reconciliar();

    expect(r.matches.single.status, 'manual_matched');
  });

  test('par rejeitado não volta a ser sugerido', () async {
    await transacoes.criar(descricao: 'Café', valor: -50, data: dia, categoria: 'x');
    await linha(50, dia.add(const Duration(days: 2)));
    final candidato = (await reconciliar()).matches.single;

    await repository.rejeitarMatch(candidato.id);
    final r = await reconciliar();

    expect(r.matches.map((m) => m.status), ['orphan']);
  });

  group('vínculo manual', () {
    test('liga a linha órfã à transação escolhida e remove a órfã', () async {
      final t = await transacoes.criar(descricao: 'Mercado', valor: -77, data: dia, categoria: 'x');
      await linha(80, dia);
      final orfa = (await reconciliar()).matches.single;
      expect(orfa.status, 'orphan');

      final vinculo = await repository.criarMatchManual(
        transacaoId: t.id,
        linhaExtratoId: orfa.linhaExtratoId,
      );

      expect(vinculo.isRight(), isTrue);
      final r = await reconciliar();
      expect(r.matches.map((m) => m.status), ['manual_matched']);
      expect(r.matches.single.transacaoId, t.id);
    });

    test('recusa transação que já foi vinculada a outra linha', () async {
      final t = await transacoes.criar(descricao: 'Mercado', valor: -77, data: dia, categoria: 'x');
      await linha(80, dia);
      await linha(90, dia);
      final linhas = (await reconciliar()).matches.map((m) => m.linhaExtratoId).toList();

      await repository.criarMatchManual(transacaoId: t.id, linhaExtratoId: linhas[0]);
      final segunda = await repository.criarMatchManual(transacaoId: t.id, linhaExtratoId: linhas[1]);

      expect(segunda.isLeft(), isTrue);
    });

    test('ao roubar o candidato de outra linha, a linha liberada volta a ser órfã', () async {
      final t = await transacoes.criar(descricao: 'Café', valor: -50, data: dia, categoria: 'x');
      await linha(50, dia.add(const Duration(days: 2)));
      await linha(999, dia);
      final inicial = (await reconciliar()).matches;
      final candidato = inicial.firstWhere((m) => m.status == 'unmatched');
      final orfa = inicial.firstWhere((m) => m.status == 'orphan');

      await repository.criarMatchManual(transacaoId: t.id, linhaExtratoId: orfa.linhaExtratoId);
      final r = await reconciliar();

      expect(r.matches.map((m) => m.status).toList()..sort(), ['manual_matched', 'orphan']);
      final liberada = r.matches.firstWhere((m) => m.status == 'orphan');
      expect(liberada.linhaExtratoId, candidato.linhaExtratoId);
    });
  });

  group('obterStatusPeriodo', () {
    test('conta as transações do período e as linhas reconciliadas', () async {
      await transacoes.criar(descricao: 'Café', valor: -50, data: dia, categoria: 'x');
      await transacoes.criar(descricao: 'Sem extrato', valor: -10, data: dia, categoria: 'x');
      await linha(50, dia);
      await linha(999, dia);
      await reconciliar();

      final status = (await repository.obterStatusPeriodo(userId: 'u', dataInicio: inicio, dataFim: fim))
          .getOrElse((f) => throw StateError(f.message));

      expect(status.totalTransacoes, 2);
      expect(status.totalLinhasExtrato, 2);
      expect(status.matched, 1);
      expect(status.orphans, 1);
    });
  });
}
