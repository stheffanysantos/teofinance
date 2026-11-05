import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/features/budget/data/datasources/orcamento_local_datasource.dart';
import 'package:teofinance/features/budget/data/repositories/orcamento_repository_impl.dart';
import 'package:teofinance/features/cartao/data/datasources/cartao_local_data_source.dart';
import 'package:teofinance/features/cartao/data/repositories/cartao_repository_impl.dart';
import 'package:teofinance/features/categoria/data/datasources/categoria_local_data_source.dart';
import 'package:teofinance/features/categoria/data/repositories/categoria_repository_impl.dart';
import 'package:teofinance/features/contas/data/datasources/conta_local_datasource.dart';
import 'package:teofinance/features/contas/data/repositories/conta_repository_impl.dart';
import 'package:teofinance/features/import/data/datasources/perfil_banco_local_datasource.dart';
import 'package:teofinance/features/import/data/repositories/perfil_banco_repository_impl.dart';
import 'package:teofinance/features/import/data/services/bank_profile_matcher.dart';
import 'package:teofinance/features/investimento/data/datasources/investimento_local_data_source.dart';
import 'package:teofinance/features/investimento/data/repositories/investimento_repository_impl.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/lembrete/data/datasources/lembrete_local_data_source.dart';
import 'package:teofinance/features/lembrete/data/repositories/lembrete_repository_impl.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';
import 'package:teofinance/features/meta/data/datasources/meta_local_datasource.dart';
import 'package:teofinance/features/meta/data/repositories/meta_repository_impl.dart';
import 'package:teofinance/features/parcelamento/data/datasources/parcelamento_local_data_source.dart';
import 'package:teofinance/features/parcelamento/data/repositories/parcelamento_repository_impl.dart';
import 'package:teofinance/features/renda/data/datasources/renda_local_datasource.dart';
import 'package:teofinance/features/renda/data/repositories/renda_repository_impl.dart';
import 'package:teofinance/features/sync/data/sync_engine.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';
import 'package:teofinance/features/transacao/data/repositories/transacao_repository_impl.dart';

/// Um aparelho: banco local próprio + engine apontando para o Firestore dado.
class _Aparelho {
  _Aparelho(FirebaseFirestore firestore) {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final transacoes = TransacaoLocalDataSource(db);
    categorias = CategoriaRepositoryImpl(CategoriaLocalDataSource(db));
    investimentos = InvestimentoRepositoryImpl(InvestimentoLocalDataSource(db));
    lembretes = LembreteRepositoryImpl(LembreteLocalDataSource(db));
    cartoes = CartaoRepositoryImpl(CartaoLocalDataSource(db));
    engine = SyncEngine(
      firestore: firestore,
      uid: 'u1',
      transacaoRepository: TransacaoRepositoryImpl(transacoes),
      perfilBancoRepository: PerfilBancoRepositoryImpl(PerfilBancoLocalDataSource(db), BankProfileMatcher()),
      rendaRepository: RendaRepositoryImpl(RendaLocalDataSource(db)),
      metaRepository: MetaRepositoryImpl(MetaLocalDataSource(db)),
      parcelamentoRepository: ParcelamentoRepositoryImpl(ParcelamentoLocalDataSourceImpl(db), transacoes),
      orcamentoRepository: OrcamentoRepositoryImpl(OrcamentoLocalDataSource(db)),
      contaRepository: ContaRepositoryImpl(ContaLocalDataSource(db)),
      categoriaRepository: categorias,
      investimentoRepository: investimentos,
      lembreteRepository: lembretes,
      cartaoRepository: cartoes,
    );
  }

  late final AppDatabase db;
  late final CategoriaRepositoryImpl categorias;
  late final InvestimentoRepositoryImpl investimentos;
  late final LembreteRepositoryImpl lembretes;
  late final CartaoRepositoryImpl cartoes;
  late final SyncEngine engine;

  Future<List<String>> nomesCategorias() async => (await categorias.listar()).getOrElse((_) => []);
}

Investimento _cdb({String id = 'i1', double atual = 1050}) => Investimento(
      id: id,
      nome: 'CDB Banco X',
      tipo: TipoInvestimento.cdb,
      valorInvestido: 1000,
      valorAtual: atual,
      dataAplicacao: DateTime(2026, 10, 1),
    );

void main() {
  late FakeFirebaseFirestore nuvem;

  setUp(() => nuvem = FakeFirebaseFirestore());

  CollectionReference<Map<String, dynamic>> colecao(String nome) =>
      nuvem.collection('users').doc('u1').collection(nome);

  test('categoria: envia, outro aparelho recebe e exclusão também se propaga', () async {
    final a = _Aparelho(nuvem);
    await a.categorias.adicionar('Pets');
    await a.categorias.adicionar('Viagem/2026');
    await a.engine.sincronizarTudo();

    expect((await colecao('categorias').get()).docs, hasLength(2));

    final b = _Aparelho(nuvem);
    await b.engine.sincronizarTudo();
    expect(await b.nomesCategorias(), containsAll(['Pets', 'Viagem/2026']));

    await a.categorias.remover('Pets');
    expect(await a.nomesCategorias(), isNot(contains('Pets')));
    await a.engine.sincronizarTudo();
    expect((await colecao('categorias').get()).docs, hasLength(1));

    await b.engine.sincronizarTudo();
    expect(await b.nomesCategorias(), ['Viagem/2026']);
  });

  test('investimento: envia, edição e exclusão se propagam, e o valor chega certo', () async {
    final a = _Aparelho(nuvem);
    await a.investimentos.salvar(_cdb());
    await a.engine.sincronizarTudo();

    final doc = (await colecao('investimentos').doc('i1').get()).data()!;
    expect(doc['valorAtual'], 1050);
    expect(doc['tipo'], 'cdb');

    final b = _Aparelho(nuvem);
    await b.engine.sincronizarTudo();
    var itens = (await b.investimentos.listar()).getOrElse((_) => []);
    expect(itens.single.valorAtual, 1050);

    await a.investimentos.salvar(_cdb(atual: 1100));
    await a.engine.sincronizarTudo();
    await b.engine.sincronizarTudo();
    itens = (await b.investimentos.listar()).getOrElse((_) => []);
    expect(itens.single.valorAtual, 1100);

    await a.investimentos.excluir('i1');
    await a.engine.sincronizarTudo();
    await b.engine.sincronizarTudo();
    expect((await b.investimentos.listar()).getOrElse((_) => [_cdb()]), isEmpty);
    expect((await colecao('investimentos').get()).docs, isEmpty);
  });

  test('lembrete personalizado: sincroniza e preserva o estado ativo', () async {
    final a = _Aparelho(nuvem);
    await a.lembretes.salvar(const LembretePersonalizado(
      id: 'l1',
      titulo: 'Nubank',
      tipo: TipoLembrete.faturaFecha,
      dia: 12,
      ativo: false,
    ));
    await a.engine.sincronizarTudo();

    final b = _Aparelho(nuvem);
    await b.engine.sincronizarTudo();
    final l = (await b.lembretes.listar()).getOrElse((_) => []).single;

    expect(l.titulo, 'Nubank');
    expect(l.tipo, TipoLembrete.faturaFecha);
    expect(l.dia, 12);
    expect(l.ativo, isFalse);
  });

  test('alteração local pendente não é sobrescrita pelo que veio da nuvem', () async {
    final a = _Aparelho(nuvem);
    await a.investimentos.salvar(_cdb());
    await a.engine.sincronizarTudo();

    // edita localmente (pendente) e, antes de sincronizar, a nuvem muda por outro aparelho
    await a.investimentos.salvar(_cdb(atual: 2000));
    await colecao('investimentos').doc('i1').update({'valorAtual': 1}).then((_) {});
    await a.investimentos.aplicarRemoto(_cdb(atual: 1));

    final itens = (await a.investimentos.listar()).getOrElse((_) => []);
    expect(itens.single.valorAtual, 2000);
  });

  test('itens pendentes de exclusão e criados antes do primeiro sync não somem no pull', () async {
    final a = _Aparelho(nuvem);
    await a.categorias.adicionar('Nova');

    // a nuvem ainda não conhece 'Nova': o pull não pode apagá-la localmente.
    await a.engine.sincronizarTudo();

    expect(await a.nomesCategorias(), ['Nova']);
    expect((await colecao('categorias').get()).docs, hasLength(1));
  });
}
