import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/parcelamento/data/datasources/parcelamento_local_data_source.dart';
import 'package:teofinance/features/parcelamento/data/repositories/parcelamento_repository_impl.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';

void main() {
  late AppDatabase db;
  late TransacaoLocalDataSource transacoes;
  late ParcelamentoRepositoryImpl parcelamentos;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    transacoes = TransacaoLocalDataSource(db);
    parcelamentos = ParcelamentoRepositoryImpl(
      ParcelamentoLocalDataSourceImpl(db),
      transacoes,
    );
  });
  tearDown(() => db.close());

  Future<void> parcelarNoCartao(String? cartaoId) async {
    final compra = await transacoes.criar(
      descricao: 'Shopee gatos',
      valor: -156,
      data: DateTime(2026, 11, 5),
      categoria: 'Pets',
    );
    if (cartaoId != null) {
      await transacoes.definirCartao(id: compra.id, cartaoId: cartaoId);
    }
    final r = await parcelamentos.criarParcelamento(
      transacaoId: compra.id,
      totalOriginal: 156,
      numeroParcelas: 2,
      dataPrimeira: DateTime(2026, 11, 5),
    );
    expect(r.isRight(), isTrue);
  }

  test(
    'parcelar uma compra do cartão mantém o cartão em todas as parcelas',
    () async {
      await parcelarNoCartao('nubank');

      final todas = await transacoes.observarTodas().first;
      expect(
        todas,
        hasLength(2),
        reason: 'a compra original sai, ficam só as parcelas',
      );
      expect(todas.every((t) => t.ehParcela && t.cartaoId == 'nubank'), isTrue);
    },
  );

  test('parcelar uma compra sem cartão não inventa cartão', () async {
    await parcelarNoCartao(null);

    final todas = await transacoes.observarTodas().first;
    expect(todas.every((t) => t.cartaoId == null), isTrue);
  });

  test(
    'trocar o cartão de uma parcela vale para todas, e dá para tirar o cartão',
    () async {
      await parcelarNoCartao(null);
      final primeira = (await transacoes.observarTodas().first).first;

      await transacoes.definirCartao(id: primeira.id, cartaoId: 'nubank');
      expect(
        (await transacoes.observarTodas().first).every(
          (t) => t.cartaoId == 'nubank',
        ),
        isTrue,
      );

      await transacoes.definirCartao(id: primeira.id, cartaoId: null);
      expect(
        (await transacoes.observarTodas().first).every(
          (t) => t.cartaoId == null,
        ),
        isTrue,
      );
    },
  );

  test('parcela já excluída não volta ao vincular o cartão da compra', () async {
    await parcelarNoCartao(null);
    final parcelas = await transacoes.observarTodas().first;
    // Sincronizada: a exclusão só marca a linha (tombstone) até o sync apagar no Firestore.
    await transacoes.confirmarSincronizacao(
      id: parcelas.last.id,
      remoteId: 'remoto-2',
    );
    await transacoes.excluir(parcelas.last.id);

    await transacoes.definirCartao(id: parcelas.first.id, cartaoId: 'nubank');

    final visiveis = await transacoes.observarTodas().first;
    expect(visiveis, hasLength(1));
    expect(visiveis.single.cartaoId, 'nubank');
  });

  test('compra comum: o cartão muda só nela', () async {
    final a = await transacoes.criar(
      descricao: 'A',
      valor: -10,
      data: DateTime(2026, 11, 1),
      categoria: '',
    );
    final b = await transacoes.criar(
      descricao: 'B',
      valor: -20,
      data: DateTime(2026, 11, 2),
      categoria: '',
    );

    await transacoes.definirCartao(id: a.id, cartaoId: 'nubank');

    final todas = await transacoes.observarTodas().first;
    expect(todas.firstWhere((t) => t.id == a.id).cartaoId, 'nubank');
    expect(todas.firstWhere((t) => t.id == b.id).cartaoId, isNull);
  });
}
