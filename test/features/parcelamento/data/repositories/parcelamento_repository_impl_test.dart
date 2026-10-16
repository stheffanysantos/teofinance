import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/parcelamento/data/datasources/parcelamento_local_data_source.dart';
import 'package:teofinance/features/parcelamento/data/datasources/parcelamento_remote_data_source.dart';
import 'package:teofinance/features/parcelamento/data/repositories/parcelamento_repository_impl.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';

class _RemotoNaoUsado implements ParcelamentoRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('remoto não deve ser chamado');
}

void main() {
  late AppDatabase db;
  late TransacaoLocalDataSource transacoes;
  late ParcelamentoRepositoryImpl repository;
  final dia = DateTime(2026, 10, 10);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    transacoes = TransacaoLocalDataSource(db);
    repository = ParcelamentoRepositoryImpl(
      ParcelamentoLocalDataSourceImpl(db),
      transacoes,
      _RemotoNaoUsado(),
    );
  });

  tearDown(() => db.close());

  test('parcelar uma despesa gera N parcelas negativas que somam o total', () async {
    final compra = await transacoes.criar(descricao: 'TV', valor: -300, data: dia, categoria: 'Casa');

    final resultado = await repository.criarParcelamento(
      transacaoId: compra.id,
      totalOriginal: 300,
      numeroParcelas: 3,
      dataPrimeira: dia,
    );

    expect(resultado.isRight(), isTrue);
    final todas = await transacoes.observarTodas().first;
    expect(todas, hasLength(3));
    expect(todas.every((t) => t.ehParcela && t.valor == -100), isTrue);
    expect(todas.map((t) => t.valor).reduce((a, b) => a + b), -300);
  });

  test('a compra original é removida para não contar em duplicidade', () async {
    final compra = await transacoes.criar(descricao: 'TV', valor: -300, data: dia, categoria: 'Casa');

    await repository.criarParcelamento(
      transacaoId: compra.id,
      totalOriginal: 300,
      numeroParcelas: 3,
      dataPrimeira: dia,
    );

    expect(await transacoes.obterPorId(compra.id), isNull);
  });

  test('transação inexistente devolve falha e não cria nada', () async {
    final resultado = await repository.criarParcelamento(
      transacaoId: 'nao-existe',
      totalOriginal: 300,
      numeroParcelas: 3,
      dataPrimeira: dia,
    );

    expect(resultado.isLeft(), isTrue);
    expect(await transacoes.observarTodas().first, isEmpty);
  });

  test('parcelas vencem em meses de calendário e os centavos fecham o total', () async {
    final compra = await transacoes.criar(
      descricao: 'Fone',
      valor: -100,
      data: DateTime(2026, 1, 31),
      categoria: 'Casa',
    );

    await repository.criarParcelamento(
      transacaoId: compra.id,
      totalOriginal: 100,
      numeroParcelas: 3,
      dataPrimeira: DateTime(2026, 1, 31),
    );

    final parcelas = (await transacoes.observarTodas().first).reversed.toList();
    expect(parcelas.map((p) => p.data), [
      DateTime(2026, 1, 31),
      DateTime(2026, 2, 28),
      DateTime(2026, 3, 31),
    ]);
    expect(parcelas.map((p) => p.valor), [-33.33, -33.33, -33.34]);
    expect(parcelas.map((p) => p.valorParcela), [-33.33, -33.33, -33.34]);
  });
}
