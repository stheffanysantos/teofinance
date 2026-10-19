import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/sync/sync_status.dart';
import 'package:teofinance/features/budget/data/datasources/orcamento_local_datasource.dart';
import 'package:teofinance/features/budget/data/repositories/orcamento_repository_impl.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/repositories/orcamento_repository.dart';
import 'package:teofinance/features/import/data/datasources/perfil_banco_local_datasource.dart';
import 'package:teofinance/features/import/data/repositories/perfil_banco_repository_impl.dart';
import 'package:teofinance/features/import/data/services/bank_profile_matcher.dart';
import 'package:teofinance/features/meta/data/datasources/meta_local_datasource.dart';
import 'package:teofinance/features/meta/data/repositories/meta_repository_impl.dart';
import 'package:teofinance/features/parcelamento/data/datasources/parcelamento_local_data_source.dart';
import 'package:teofinance/features/parcelamento/data/datasources/parcelamento_remote_data_source.dart';
import 'package:teofinance/features/parcelamento/data/repositories/parcelamento_repository_impl.dart';
import 'package:teofinance/features/renda/data/datasources/renda_local_datasource.dart';
import 'package:teofinance/features/renda/data/repositories/renda_repository_impl.dart';
import 'package:teofinance/features/sync/data/sync_engine.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';
import 'package:teofinance/features/transacao/data/repositories/transacao_repository_impl.dart';

/// Chaves que `firestore.rules` (branch feature/firestore-rules) aceita em
/// `users/{uid}/parcelamentos/{id}`. O push nunca pode mandar outra.
const _chavesPermitidasParcelamento = {
  'id', 'remoteId', 'transacaoOriginalId', 'totalOriginal',
  'numeroParcelas', 'dataPrimeiraParc', 'updatedAt',
};
const _chavesObrigatoriasParcelamento = {
  'id', 'transacaoOriginalId', 'totalOriginal',
  'numeroParcelas', 'dataPrimeiraParc', 'updatedAt',
};

/// Firestore que nunca responde: simula o aparelho sem conexão.
class _FirestoreOffline implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'sem conexão',
      );
}

/// Orçamento cujo repository quebra ao listar pendências: uma entidade com
/// defeito não pode impedir as demais de sincronizar.
class _OrcamentoQuebrado extends OrcamentoRepositoryImpl {
  _OrcamentoQuebrado(super.local);

  @override
  Future<List<Orcamento>> listarPendentesDeSincronizacao() => throw StateError('quebrou');
}

/// Um aparelho: banco local próprio + engine apontando para o Firestore dado.
class _Aparelho {
  _Aparelho(this.firestore, {OrcamentoRepository Function(OrcamentoLocalDataSource)? orcamento}) {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    transacoes = TransacaoLocalDataSource(db);
    orcamentos = OrcamentoLocalDataSource(db);
    final parcelamentoLocal = ParcelamentoLocalDataSourceImpl(db);
    parcelamentoRepo = ParcelamentoRepositoryImpl(
      parcelamentoLocal,
      transacoes,
      ParcelamentoRemoteDataSourceImpl(firestore),
    );
    engine = SyncEngine(
      firestore: firestore,
      uid: 'u1',
      transacaoRepository: TransacaoRepositoryImpl(transacoes),
      perfilBancoRepository: PerfilBancoRepositoryImpl(PerfilBancoLocalDataSource(db), BankProfileMatcher()),
      rendaRepository: RendaRepositoryImpl(RendaLocalDataSource(db)),
      metaRepository: MetaRepositoryImpl(MetaLocalDataSource(db)),
      parcelamentoRepository: parcelamentoRepo,
      orcamentoRepository: (orcamento ?? OrcamentoRepositoryImpl.new)(orcamentos),
    );
  }

  final FirebaseFirestore firestore;
  late final AppDatabase db;
  late final TransacaoLocalDataSource transacoes;
  late final OrcamentoLocalDataSource orcamentos;
  late final ParcelamentoRepositoryImpl parcelamentoRepo;
  late final SyncEngine engine;

  Future<List<TransactionsTableData>> linhasTransacao() => db.select(db.transactionsTable).get();
  Future<List<OrcamentoTableData>> linhasOrcamento() => db.select(db.orcamentoTable).get();
  Future<List<ParcelamentoTableData>> linhasParcelamento() => db.select(db.parcelamentoTable).get();

  Future<void> fechar() => db.close();
}

CollectionReference<Map<String, dynamic>> _colecao(FirebaseFirestore f, String nome) =>
    f.collection('users').doc('u1').collection(nome);

void main() {
  late FakeFirebaseFirestore nuvem;
  final abertos = <_Aparelho>[];

  _Aparelho novoAparelho([FirebaseFirestore? firestore, OrcamentoRepository Function(OrcamentoLocalDataSource)? orcamento]) {
    final a = _Aparelho(firestore ?? nuvem, orcamento: orcamento);
    abertos.add(a);
    return a;
  }

  setUp(() => nuvem = FakeFirebaseFirestore());

  tearDown(() async {
    for (final a in abertos) {
      await a.fechar();
    }
    abertos.clear();
  });

  group('parcelamento', () {
    Future<void> comprarEmTres(_Aparelho a) async {
      final compra = await a.transacoes.criar(
        descricao: 'Notebook',
        valor: -300,
        data: DateTime(2026, 10, 10),
        categoria: 'Lazer',
      );
      await a.parcelamentoRepo.criarParcelamento(
        transacaoId: compra.id,
        totalOriginal: 300,
        numeroParcelas: 3,
        dataPrimeira: DateTime(2026, 10, 10),
      );
    }

    test('envia o parcelamento exatamente no formato que as regras aceitam', () async {
      final a = novoAparelho();
      await comprarEmTres(a);

      await a.engine.sincronizarTudo();

      final docs = (await _colecao(nuvem, 'parcelamentos').get()).docs;
      expect(docs, hasLength(1));
      final chaves = docs.single.data().keys.toSet();
      expect(chaves.difference(_chavesPermitidasParcelamento), isEmpty);
      expect(chaves.containsAll(_chavesObrigatoriasParcelamento), isTrue);
      expect(docs.single.data()['dataPrimeiraParc'], isA<String>());
      expect(docs.single.data()['updatedAt'], isA<String>());
      expect(docs.single.data()['numeroParcelas'], 3);
    });

    test('as parcelas vão para o Firestore com a estrutura de parcela', () async {
      final a = novoAparelho();
      await comprarEmTres(a);

      await a.engine.sincronizarTudo();

      final docs = (await _colecao(nuvem, 'transacoes').get()).docs.map((d) => d.data()).toList();
      final parcelas = docs.where((d) => d['ehParcela'] == true).toList();
      expect(parcelas, hasLength(3));
      expect(parcelas.map((p) => p['numeroParcela']).toSet(), {1, 2, 3});
      expect(parcelas.every((p) => p['parcelamentoId'] != null), isTrue);
      expect(parcelas.every((p) => p['statusParcela'] == 'pendente'), isTrue);
      expect(parcelas.fold<double>(0, (soma, p) => soma + (p['valorParcela'] as num)), closeTo(-300, 0.001));
    });

    test('um segundo aparelho recupera o parcelamento e as parcelas com a estrutura', () async {
      final a = novoAparelho();
      await comprarEmTres(a);
      await a.engine.sincronizarTudo();

      final b = novoAparelho();
      await b.engine.sincronizarTudo();

      final parcelas = (await b.linhasTransacao()).where((t) => t.ehParcela).toList();
      expect(parcelas, hasLength(3));
      expect(parcelas.every((p) => p.parcelamentoId != null && p.numeroParcela != null), isTrue);
      final parcelamentos = await b.linhasParcelamento();
      expect(parcelamentos, hasLength(1));
      expect(parcelamentos.single.id, parcelas.first.parcelamentoId);
      expect(parcelamentos.single.syncStatus, SyncStatus.synced);
    });

    test('depois de sincronizar, o parcelamento deixa de estar pendente', () async {
      final a = novoAparelho();
      await comprarEmTres(a);

      await a.engine.sincronizarTudo();

      expect((await a.linhasParcelamento()).single.syncStatus, SyncStatus.synced);
    });
  });

  group('orçamento', () {
    test('envia o limite e confirma como sincronizado', () async {
      final a = novoAparelho();
      await a.orcamentos.definirLimite(categoria: 'Mercado', limite: 500);

      await a.engine.sincronizarTudo();

      final docs = (await _colecao(nuvem, 'orcamentos').get()).docs;
      expect(docs.single.data(), {'categoria': 'Mercado', 'limite': 500.0});
      final linha = (await a.linhasOrcamento()).single;
      expect(linha.syncStatus, SyncStatus.synced);
      expect(linha.remoteId, docs.single.id);
    });

    test('editar o limite depois de sincronizado reenvia o valor novo', () async {
      final a = novoAparelho();
      await a.orcamentos.definirLimite(categoria: 'Mercado', limite: 500);
      await a.engine.sincronizarTudo();

      await a.orcamentos.definirLimite(categoria: 'Mercado', limite: 650);
      expect((await a.linhasOrcamento()).single.syncStatus, SyncStatus.pendingUpdate);
      await a.engine.sincronizarTudo();

      final docs = (await _colecao(nuvem, 'orcamentos').get()).docs;
      expect(docs, hasLength(1));
      expect(docs.single.data()['limite'], 650.0);
    });

    test('excluir um limite já sincronizado apaga o documento remoto e não ressuscita', () async {
      final a = novoAparelho();
      final criado = await a.orcamentos.definirLimite(categoria: 'Mercado', limite: 500);
      await a.engine.sincronizarTudo();

      await a.orcamentos.excluir(criado.id);
      expect((await a.orcamentos.observarTodos().first), isEmpty);
      await a.engine.sincronizarTudo();

      expect((await _colecao(nuvem, 'orcamentos').get()).docs, isEmpty);
      expect(await a.linhasOrcamento(), isEmpty);
    });

    test('excluir um limite que nunca foi enviado some só do aparelho', () async {
      final a = novoAparelho();
      final criado = await a.orcamentos.definirLimite(categoria: 'Lazer', limite: 100);

      await a.orcamentos.excluir(criado.id);

      expect(await a.linhasOrcamento(), isEmpty);
    });

    test('um segundo aparelho recebe os limites', () async {
      final a = novoAparelho();
      await a.orcamentos.definirLimite(categoria: 'Mercado', limite: 500);
      await a.engine.sincronizarTudo();

      final b = novoAparelho();
      await b.engine.sincronizarTudo();

      final limites = await b.orcamentos.observarTodos().first;
      expect(limites.map((o) => (o.categoria, o.limite)), [('Mercado', 500.0)]);
    });

    test('conflito: o limite editado localmente e ainda não enviado vence o remoto', () async {
      final a = novoAparelho();
      await a.orcamentos.definirLimite(categoria: 'Mercado', limite: 500);
      await a.engine.sincronizarTudo();
      final remoteId = (await a.linhasOrcamento()).single.remoteId!;

      await a.orcamentos.definirLimite(categoria: 'Mercado', limite: 700);
      await _colecao(nuvem, 'orcamentos').doc(remoteId).set({'categoria': 'Mercado', 'limite': 900.0});
      await a.orcamentos.aplicarRemoto(remoteId: remoteId, categoria: 'Mercado', limite: 900);

      expect((await a.linhasOrcamento()).single.limite, 700);
    });

    test('categoria única: limite remoto da mesma categoria não duplica o local já sincronizado', () async {
      final a = novoAparelho();
      await a.orcamentos.definirLimite(categoria: 'Mercado', limite: 500);
      await a.engine.sincronizarTudo();

      await a.orcamentos.aplicarRemoto(remoteId: 'outro-aparelho', categoria: 'Mercado', limite: 800);

      final linhas = await a.linhasOrcamento();
      expect(linhas, hasLength(1));
      expect(linhas.single.limite, 800);
    });
  });

  group('sem conexão e falha parcial', () {
    test('sem conexão nada é perdido: tudo continua pendente e a próxima rodada envia', () async {
      final a = novoAparelho(_FirestoreOffline());
      await a.orcamentos.definirLimite(categoria: 'Mercado', limite: 500);
      await a.transacoes.criar(descricao: 'Café', valor: -10, data: DateTime(2026, 10, 1), categoria: 'Mercado');

      await a.engine.sincronizarTudo(); // não pode lançar

      expect((await a.linhasOrcamento()).single.syncStatus, SyncStatus.pendingCreate);
      expect((await a.linhasTransacao()).single.syncStatus, SyncStatus.pendingCreate);

      final online = novoAparelho(nuvem);
      final mesmoBanco = SyncEngine(
        firestore: nuvem,
        uid: 'u1',
        transacaoRepository: TransacaoRepositoryImpl(a.transacoes),
        perfilBancoRepository: PerfilBancoRepositoryImpl(PerfilBancoLocalDataSource(a.db), BankProfileMatcher()),
        rendaRepository: RendaRepositoryImpl(RendaLocalDataSource(a.db)),
        metaRepository: MetaRepositoryImpl(MetaLocalDataSource(a.db)),
        parcelamentoRepository: a.parcelamentoRepo,
        orcamentoRepository: OrcamentoRepositoryImpl(a.orcamentos),
      );
      await mesmoBanco.sincronizarTudo();

      expect((await a.linhasOrcamento()).single.syncStatus, SyncStatus.synced);
      expect((await a.linhasTransacao()).single.syncStatus, SyncStatus.synced);
      expect(online, isNotNull);
    });

    test('uma entidade quebrada não impede as outras de sincronizar', () async {
      final a = novoAparelho(null, _OrcamentoQuebrado.new);
      await a.orcamentos.definirLimite(categoria: 'Mercado', limite: 500);
      await a.transacoes.criar(descricao: 'Café', valor: -10, data: DateTime(2026, 10, 1), categoria: 'Mercado');

      await a.engine.sincronizarTudo();

      expect((await _colecao(nuvem, 'transacoes').get()).docs, hasLength(1));
      expect((await a.linhasOrcamento()).single.syncStatus, SyncStatus.pendingCreate);
    });

    test('documento remoto malformado é ignorado sem derrubar o restante do pull', () async {
      await _colecao(nuvem, 'orcamentos').doc('ruim').set({'categoria': 'Lazer'}); // sem limite
      await _colecao(nuvem, 'orcamentos').doc('bom').set({'categoria': 'Mercado', 'limite': 300});

      final a = novoAparelho();
      await a.engine.sincronizarTudo();

      final limites = await a.orcamentos.observarTodos().first;
      expect(limites.map((o) => o.categoria), ['Mercado']);
    });
  });
}
