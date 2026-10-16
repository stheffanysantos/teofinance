import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';

void main() {
  late AppDatabase db;
  late TransacaoLocalDataSource datasource;
  final dia = DateTime(2026, 10, 10);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = TransacaoLocalDataSource(db);
  });

  tearDown(() => db.close());

  test('excluir transação nunca enviada apaga de vez', () async {
    final t = await datasource.criar(descricao: 'Café', valor: -10, data: dia, categoria: 'Alimentação');

    await datasource.excluir(t.id);

    expect(await datasource.listarPendentesDeExclusao(), isEmpty);
    expect(await datasource.obterPorId(t.id), isNull);
  });

  test('excluir transação já sincronizada só marca pendingDelete e some das listas', () async {
    final t = await datasource.criar(descricao: 'Mercado', valor: -80, data: dia, categoria: 'Mercado');
    await datasource.confirmarSincronizacao(id: t.id, remoteId: 'remoto-1');

    await datasource.excluir(t.id);

    expect(await datasource.obterPorId(t.id), isNull);
    expect(await datasource.listarPorPeriodo(dia, dia.add(const Duration(days: 1))), isEmpty);
    expect(await datasource.observarTodas().first, isEmpty);
    final pendentes = await datasource.listarPendentesDeExclusao();
    expect(pendentes.single.remoteId, 'remoto-1');
    expect(await datasource.listarPendentes(), isEmpty);
  });

  test('pull do Firestore não ressuscita transação com exclusão pendente', () async {
    final t = await datasource.criar(descricao: 'Mercado', valor: -80, data: dia, categoria: 'Mercado');
    await datasource.confirmarSincronizacao(id: t.id, remoteId: 'remoto-1');
    await datasource.excluir(t.id);

    await datasource.aplicarRemoto(
      remoteId: 'remoto-1',
      descricao: 'Mercado',
      categoria: 'Mercado',
      valor: -80,
      data: dia,
      precisaCategoria: false,
    );

    expect(await datasource.observarTodas().first, isEmpty);
  });

  test('confirmarExclusao remove o registro marcado', () async {
    final t = await datasource.criar(descricao: 'Mercado', valor: -80, data: dia, categoria: 'Mercado');
    await datasource.confirmarSincronizacao(id: t.id, remoteId: 'remoto-1');
    await datasource.excluir(t.id);

    await datasource.confirmarExclusao(t.id);

    expect(await datasource.listarPendentesDeExclusao(), isEmpty);
  });
}
