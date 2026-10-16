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

  test('definirDivisao grava parte e nomes, marca pendingUpdate e dá para remover', () async {
    final t = await datasource.criar(descricao: 'Pizza', valor: -100, data: dia, categoria: 'Comida');
    await datasource.confirmarSincronizacao(id: t.id, remoteId: 'remoto-1');

    await datasource.definirDivisao(id: t.id, minhaParte: 33.33, divididoCom: ['Ana', 'Bruno']);

    var salva = (await datasource.obterPorId(t.id))!;
    expect(salva.minhaParte, 33.33);
    expect(salva.divididoCom, ['Ana', 'Bruno']);
    expect(salva.valorContabilizado, -33.33);
    expect((await datasource.listarPendentes()).map((x) => x.id), [t.id]);

    await datasource.definirDivisao(id: t.id, minhaParte: null, divididoCom: const []);

    salva = (await datasource.obterPorId(t.id))!;
    expect(salva.ehDividida, isFalse);
    expect(salva.divididoCom, isEmpty);
  });

  test('aplicarRemoto traz a divisão de outro aparelho', () async {
    await datasource.aplicarRemoto(
      remoteId: 'remoto-2',
      descricao: 'Pizza',
      categoria: 'Comida',
      valor: -100,
      data: dia,
      precisaCategoria: false,
      minhaParte: 25,
      divididoCom: ['Ana', 'Bruno', 'Carla'],
    );

    final todas = await datasource.observarTodas().first;
    expect(todas.single.minhaParte, 25);
    expect(todas.single.divididoCom, ['Ana', 'Bruno', 'Carla']);
  });
}
