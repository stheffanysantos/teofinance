import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/cartao/data/datasources/cartao_local_data_source.dart';
import 'package:teofinance/features/cartao/data/repositories/cartao_repository_impl.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/periodo_fatura.dart';
import 'package:teofinance/features/cartao/domain/services/resumo_faturas.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/cartao/domain/usecases/pagamento_fatura_usecases.dart';
import 'package:teofinance/features/cartao/domain/usecases/salvar_cartao_usecase.dart';
import 'package:teofinance/features/lembrete/data/datasources/lembrete_local_data_source.dart';
import 'package:teofinance/features/lembrete/data/repositories/lembrete_repository_impl.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';

void main() {
  group('periodoDaFatura', () {
    test('fecha dia 25 e vence dia 5: a fatura de novembro cobre 25/09 a 24/10', () {
      final p = periodoDaFatura(diaFechamento: 25, diaVencimento: 5, ano: 2026, mes: 11);

      expect(p.inicio, DateTime(2026, 9, 25));
      expect(p.fim, DateTime(2026, 10, 25));
      expect(p.vencimento, DateTime(2026, 11, 5));
    });

    test('fecha dia 5 e vence dia 12 no mesmo mês', () {
      final p = periodoDaFatura(diaFechamento: 5, diaVencimento: 12, ano: 2026, mes: 11);

      expect(p.inicio, DateTime(2026, 10, 5));
      expect(p.fim, DateTime(2026, 11, 5));
      expect(p.vencimento, DateTime(2026, 11, 12));
    });

    test('compra no dia do fechamento entra na próxima fatura', () {
      final p = periodoDaFatura(diaFechamento: 25, diaVencimento: 5, ano: 2026, mes: 11);

      expect(p.contem(DateTime(2026, 9, 25)), isTrue);
      expect(p.contem(DateTime(2026, 10, 24, 23, 59)), isTrue);
      expect(p.contem(DateTime(2026, 10, 25)), isFalse);
      expect(p.contem(DateTime(2026, 9, 24)), isFalse);
    });

    test('virada de ano e mês curto (fecha dia 31)', () {
      final jan = periodoDaFatura(diaFechamento: 28, diaVencimento: 8, ano: 2027, mes: 1);
      expect(jan.inicio, DateTime(2026, 11, 28));
      expect(jan.fim, DateTime(2026, 12, 28));

      final fev = periodoDaFatura(diaFechamento: 31, diaVencimento: 10, ano: 2026, mes: 3);
      expect(fev.fim, DateTime(2026, 2, 28));
      expect(fev.inicio, DateTime(2026, 1, 31));
    });

    test('faturaAberta devolve a fatura que contém hoje', () {
      final r = faturaAberta(diaFechamento: 25, diaVencimento: 5, hoje: DateTime(2026, 11, 2));
      // compras de 25/10 a 24/11 → vence em 5/12
      expect(r, (ano: 2026, mes: 12));
    });
  });

  group('cartões e pagamentos', () {
    late AppDatabase db;
    late CartaoRepositoryImpl repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = CartaoRepositoryImpl(CartaoLocalDataSource(db));
    });
    tearDown(() => db.close());

    test('cria, edita e exclui um cartão; valida nome e dias', () async {
      final salvar = SalvarCartaoUseCase(repo, LembreteRepositoryImpl(LembreteLocalDataSource(db)));

      expect((await salvar(const Cartao(id: '', nome: ' ', diaFechamento: 5, diaVencimento: 10))).isLeft(), isTrue);
      expect((await salvar(const Cartao(id: '', nome: 'X', diaFechamento: 0, diaVencimento: 10))).isLeft(), isTrue);

      await salvar(const Cartao(id: '', nome: 'Nubank', diaFechamento: 25, diaVencimento: 5, limite: 5000));
      var cartoes = (await repo.listarCartoes()).getOrElse((_) => []);
      expect(cartoes.single.limite, 5000);

      await salvar(cartoes.single.copyWith(diaFechamento: 20));
      cartoes = (await repo.listarCartoes()).getOrElse((_) => []);
      expect(cartoes.single.diaFechamento, 20);

      await repo.excluirCartao(cartoes.single.id);
      expect((await repo.listarCartoes()).getOrElse((_) => []), isEmpty);
    });

    test('marcar a fatura como paga e desfazer; não cria transação', () async {
      final pagamento = FaturaPaga(cartaoId: 'c1', ano: 2026, mes: 11, valor: 1629.05, dataPagamento: DateTime(2026, 11, 5));

      await RegistrarPagamentoFaturaUseCase(repo)(pagamento);
      var lista = (await repo.listarPagamentos()).getOrElse((_) => []);
      expect(lista.single.valor, 1629.05);

      expect(await TransacaoLocalDataSource(db).observarTodas().first, isEmpty);

      await DesfazerPagamentoFaturaUseCase(repo)(cartaoId: 'c1', ano: 2026, mes: 11);
      lista = (await repo.listarPagamentos()).getOrElse((_) => []);
      expect(lista, isEmpty);
    });

    test('vincular compras a um cartão grava o cartaoId', () async {
      final transacoes = TransacaoLocalDataSource(db);
      final a = await transacoes.criar(descricao: 'A', valor: -10, data: DateTime(2026, 10, 10), categoria: '');
      final b = await transacoes.criar(descricao: 'B', valor: -20, data: DateTime(2026, 10, 11), categoria: '');

      await transacoes.vincularCartao(ids: [a.id, b.id], cartaoId: 'c1');

      final todas = await transacoes.observarTodas().first;
      expect(todas.every((t) => t.cartaoId == 'c1'), isTrue);
    });
  });

  test('cartão e pagamento sincronizam entre aparelhos', () async {
    final nuvem = FakeFirebaseFirestore();
    final dbA = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(dbA.close);
    final repoA = CartaoRepositoryImpl(CartaoLocalDataSource(dbA));
    await SalvarCartaoUseCase(repoA, LembreteRepositoryImpl(LembreteLocalDataSource(dbA)))(const Cartao(id: 'c1', nome: 'Nubank', diaFechamento: 25, diaVencimento: 5));
    await repoA.registrarPagamento(
      FaturaPaga(cartaoId: 'c1', ano: 2026, mes: 11, valor: 100, dataPagamento: DateTime(2026, 11, 5)),
    );

    // Empurra o que está pendente, como o SyncEngine faz.
    final colecao = nuvem.collection('users').doc('u1').collection('cartoes');
    for (final c in await repoA.cartoesPendentesDeSincronizacao()) {
      await colecao.doc(c.id).set({'nome': c.nome, 'diaFechamento': c.diaFechamento, 'diaVencimento': c.diaVencimento});
      await repoA.confirmarCartao(c.id);
    }

    expect((await colecao.get()).docs, hasLength(1));
    expect(await repoA.cartoesPendentesDeSincronizacao(), isEmpty);
    expect(await repoA.pagamentosPendentesDeSincronizacao(), hasLength(1));
    expect(Timestamp.now(), isNotNull);
  });

  group('resumo das faturas e lembretes do cartão', () {
    const cartao = Cartao(id: 'c1', nome: 'Nubank', diaFechamento: 25, diaVencimento: 5);

    Transacao compra(String id, DateTime data, double valor, {String? cartaoId = 'c1'}) =>
        Transacao(id: id, descricao: id, categoria: '', valor: valor, data: data, cartaoId: cartaoId);

    test('agrupa por fatura, ignora outros cartões e aponta o que está em aberto', () {
      final faturas = resumirFaturas(
        cartao: cartao,
        transacoes: [
          compra('a', DateTime(2026, 9, 30), -100), // vence 05/11 (compras de 25/09 a 24/10)
          compra('b', DateTime(2026, 10, 10), -50), // idem
          compra('c', DateTime(2026, 10, 30), -70), // vence 05/12
          compra('x', DateTime(2026, 10, 10), -999, cartaoId: 'outro'),
          compra('y', DateTime(2026, 10, 10), -999, cartaoId: null),
        ],
        pagamentos: [],
      );

      expect(faturas, hasLength(2));
      expect(faturas.first.total, 150);
      expect(faturas.first.periodo.vencimento, DateTime(2026, 11, 5));
      expect(faturas.last.total, 70);
      expect(faturas.every((f) => f.emAberto), isTrue);
    });

    test('fatura paga (mesmo com atraso) sai de "em aberto"; a de outro mês continua', () {
      final faturas = resumirFaturas(
        cartao: cartao,
        transacoes: [compra('a', DateTime(2026, 9, 30), -100), compra('c', DateTime(2026, 10, 30), -70)],
        pagamentos: [FaturaPaga(cartaoId: 'c1', ano: 2026, mes: 11, valor: 100, dataPagamento: DateTime(2026, 11, 20))],
      );

      expect(faturas.first.emAberto, isFalse);
      expect(faturas.last.emAberto, isTrue);
      expect(faturas.last.vencidaEm(DateTime(2026, 12, 6)), isTrue);
      expect(faturas.last.vencidaEm(DateTime(2026, 12, 5)), isFalse);
    });

    test('estorno reduz o total da fatura', () {
      final faturas = resumirFaturas(
        cartao: cartao,
        transacoes: [compra('a', DateTime(2026, 10, 1), -100), compra('e', DateTime(2026, 10, 2), 30)],
        pagamentos: [],
      );

      expect(faturas.single.total, 70);
    });

    test('salvar o cartão cria os lembretes de fechamento e vencimento; editar atualiza e preserva o desligado', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final lembretes = LembreteRepositoryImpl(LembreteLocalDataSource(db));
      final salvar = SalvarCartaoUseCase(CartaoRepositoryImpl(CartaoLocalDataSource(db)), lembretes);

      await salvar(cartao);
      var lista = (await lembretes.listar()).getOrElse((_) => []);
      expect(lista, hasLength(2));
      expect(lista.firstWhere((l) => l.id == idLembreteFechamento('c1')).dia, 25);
      expect(lista.firstWhere((l) => l.id == idLembreteVencimento('c1')).dia, 5);

      // usuário desliga o de vencimento e depois muda os dias do cartão
      final venc = lista.firstWhere((l) => l.id == idLembreteVencimento('c1'));
      await lembretes.salvar(venc.copyWith(ativo: false));
      await salvar(cartao.copyWith(diaFechamento: 20, diaVencimento: 8));

      lista = (await lembretes.listar()).getOrElse((_) => []);
      expect(lista, hasLength(2));
      expect(lista.firstWhere((l) => l.id == idLembreteFechamento('c1')).dia, 20);
      final vencDepois = lista.firstWhere((l) => l.id == idLembreteVencimento('c1'));
      expect(vencDepois.dia, 8);
      expect(vencDepois.ativo, isFalse);

      await ExcluirCartaoUseCase(CartaoRepositoryImpl(CartaoLocalDataSource(db)), lembretes)('c1');
      expect((await lembretes.listar()).getOrElse((_) => []), isEmpty);
    });
  });

  test('total em aberto soma só as faturas não pagas de todos os cartões', () {
    const a = Cartao(id: 'a', nome: 'A', diaFechamento: 25, diaVencimento: 5);
    const b = Cartao(id: 'b', nome: 'B', diaFechamento: 25, diaVencimento: 5);
    Transacao compra(String id, String cartao, DateTime d, double v) =>
        Transacao(id: id, descricao: id, categoria: '', valor: v, data: d, cartaoId: cartao);

    final total = totalEmAbertoNosCartoes(
      cartoes: [a, b],
      transacoes: [
        compra('1', 'a', DateTime(2026, 10, 10), -100), // fatura de nov, paga abaixo
        compra('2', 'a', DateTime(2026, 10, 30), -70), // fatura de dez, em aberto
        compra('3', 'b', DateTime(2026, 10, 10), -50), // em aberto
      ],
      pagamentos: [FaturaPaga(cartaoId: 'a', ano: 2026, mes: 11, valor: 100, dataPagamento: DateTime(2026, 11, 5))],
    );

    expect(total, 120);
  });
}
