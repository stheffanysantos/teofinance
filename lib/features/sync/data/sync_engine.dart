import 'package:cloud_firestore/cloud_firestore.dart';

import '../../budget/domain/repositories/orcamento_repository.dart';
import '../../cartao/domain/entities/cartao.dart';
import '../../cartao/domain/repositories/cartao_repository.dart';
import '../../categoria/domain/repositories/categoria_repository.dart';
import '../../contas/domain/entities/conta_a_pagar.dart';
import '../../contas/domain/repositories/conta_repository.dart';
import '../../import/domain/entities/campo_coluna.dart';
import '../../investimento/domain/entities/investimento.dart';
import '../../investimento/domain/repositories/investimento_repository.dart';
import '../../lembrete/domain/entities/lembrete_personalizado.dart';
import '../../lembrete/domain/repositories/lembrete_repository.dart';
import '../../import/domain/entities/perfil_banco.dart';
import '../../import/domain/repositories/perfil_banco_repository.dart';
import '../../meta/domain/entities/meta.dart';
import '../../meta/domain/repositories/meta_repository.dart';
import '../../parcelamento/domain/entities/parcelamento.dart';
import '../../parcelamento/domain/repositories/parcelamento_repository.dart';
import '../../renda/domain/entities/renda.dart';
import '../../renda/domain/repositories/renda_repository.dart';
import '../../transacao/domain/repositories/transacao_repository.dart';

/// Orquestra push (envio de pendências locais) e pull (aplicação de dados
/// remotos) para as entidades sincronizáveis — nenhuma outra
/// feature implementa sua própria lógica de sincronização (ver
/// `.claude/rules/architecture.md`, regra de sincronização, e
/// `.claude/agents/firebase-sync-engineer.md`).
///
/// Uma falha ao sincronizar um item nunca impede os demais — cada entidade,
/// e cada item dentro dela, é tratado de forma independente.
class SyncEngine {
  SyncEngine({
    required FirebaseFirestore firestore,
    required String uid,
    required TransacaoRepository transacaoRepository,
    required PerfilBancoRepository perfilBancoRepository,
    required RendaRepository rendaRepository,
    required MetaRepository metaRepository,
    required ParcelamentoRepository parcelamentoRepository,
    required OrcamentoRepository orcamentoRepository,
    required ContaRepository contaRepository,
    required CategoriaRepository categoriaRepository,
    required InvestimentoRepository investimentoRepository,
    required LembreteRepository lembreteRepository,
    required CartaoRepository cartaoRepository,
    Future<bool> Function()? pausado,
  }) : _firestore = firestore,
       _uid = uid,
       _transacaoRepository = transacaoRepository,
       _perfilBancoRepository = perfilBancoRepository,
       _rendaRepository = rendaRepository,
       _metaRepository = metaRepository,
       _parcelamentoRepository = parcelamentoRepository,
       _orcamentoRepository = orcamentoRepository,
       _contaRepository = contaRepository,
       _categoriaRepository = categoriaRepository,
       _investimentoRepository = investimentoRepository,
       _lembreteRepository = lembreteRepository,
       _cartaoRepository = cartaoRepository,
       _pausado = pausado;

  final FirebaseFirestore _firestore;
  final String _uid;
  final TransacaoRepository _transacaoRepository;
  final PerfilBancoRepository _perfilBancoRepository;
  final RendaRepository _rendaRepository;
  final MetaRepository _metaRepository;
  final ParcelamentoRepository _parcelamentoRepository;
  final OrcamentoRepository _orcamentoRepository;
  final ContaRepository _contaRepository;
  final CategoriaRepository _categoriaRepository;
  final InvestimentoRepository _investimentoRepository;
  final LembreteRepository _lembreteRepository;
  final CartaoRepository _cartaoRepository;

  /// Quando devolve `true` o sync não roda (exclusão de conta interrompida).
  final Future<bool> Function()? _pausado;

  CollectionReference<Map<String, dynamic>> _colecao(String nome) {
    return _firestore.collection('users').doc(_uid).collection(nome);
  }

  Future<void> sincronizarTudo() async {
    if (_pausado != null && await _pausado()) return;

    // Cada entidade roda isoladamente — uma falhar não impede as outras.
    // Parcelamentos antes das transações: as parcelas apontam para eles.
    await _tentar(_sincronizarParcelamentos);
    await _tentar(_sincronizarTransacoes);
    await _tentar(_sincronizarPerfisBanco);
    await _tentar(_sincronizarRendas);
    await _tentar(_sincronizarMetas);
    await _tentar(_sincronizarOrcamentos);
    await _tentar(_sincronizarContas);
    await _tentar(_sincronizarCategorias);
    await _tentar(_sincronizarInvestimentos);
    await _tentar(_sincronizarLembretes);
    await _tentar(_sincronizarCartoes);
    await _tentar(_sincronizarFaturasPagas);
  }

  static const _tempoMaximoPorEntidade = Duration(seconds: 40);

  Future<void> _tentar(Future<void> Function() sincronizar) async {
    try {
      // Sem teto, uma chamada ao Firestore que nunca responde (aparelho sem
      // conexão, regra negando a escrita) deixaria "Sincronizar" girando para sempre.
      await sincronizar().timeout(_tempoMaximoPorEntidade);
    } catch (_) {
      // Erro de uma entidade não deve quebrar a sincronização das demais;
      // a próxima rodada (próxima abertura do app) tenta de novo.
    }
  }

  // ---------------------------------------------------------------------
  // Transações
  // ---------------------------------------------------------------------

  Future<void> _sincronizarTransacoes() async {
    final colecao = _colecao('transacoes');

    final paraExcluir = await _transacaoRepository.listarPendentesDeExclusao();
    for (final transacao in paraExcluir) {
      try {
        await colecao.doc(transacao.remoteId).delete();
        await _transacaoRepository.confirmarExclusao(transacao.id);
      } catch (_) {
        // mantém pendingDelete — a próxima rodada tenta de novo.
      }
    }

    final pendentes = await _transacaoRepository.listarPendentesDeSincronizacao();
    for (final transacao in pendentes) {
      try {
        final doc = colecao.doc(transacao.id);
        await doc.set({
          'descricao': transacao.descricao,
          'categoria': transacao.categoria,
          'valor': transacao.valor,
          'data': Timestamp.fromDate(transacao.data),
          'minhaParte': transacao.minhaParte,
          'divididoCom': transacao.divididoCom,
          'parcelamentoId': transacao.parcelamentoId,
          'numeroParcela': transacao.numeroParcela,
          'valorParcela': transacao.valorParcela,
          'ehParcela': transacao.ehParcela,
          'statusParcela': transacao.statusParcela,
          'cartaoId': transacao.cartaoId,
        });
        await _transacaoRepository.confirmarSincronizacao(id: transacao.id, remoteId: doc.id);
      } catch (_) {
        // item isolado — segue para o próximo.
      }
    }

    final remotos = await colecao.get();
    for (final doc in remotos.docs) {
      try {
        final dados = doc.data();
        await _transacaoRepository.aplicarRemoto(
          remoteId: doc.id,
          descricao: dados['descricao'] as String? ?? '',
          categoria: dados['categoria'] as String? ?? '',
          valor: (dados['valor'] as num?)?.toDouble() ?? 0,
          data: (dados['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
          precisaCategoria: (dados['categoria'] as String? ?? '').trim().isEmpty,
          minhaParte: (dados['minhaParte'] as num?)?.toDouble(),
          divididoCom: ((dados['divididoCom'] as List?) ?? const []).cast<String>(),
          parcelamentoId: dados['parcelamentoId'] as String?,
          numeroParcela: (dados['numeroParcela'] as num?)?.toInt(),
          valorParcela: (dados['valorParcela'] as num?)?.toDouble(),
          ehParcela: dados['ehParcela'] as bool? ?? false,
          statusParcela: dados['statusParcela'] as String?,
        );
        await _transacaoRepository.aplicarCartaoRemoto(remoteId: doc.id, cartaoId: dados['cartaoId'] as String?);
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------
  // Perfis de Banco
  // ---------------------------------------------------------------------

  Future<void> _sincronizarPerfisBanco() async {
    final colecao = _colecao('perfis_banco');

    final pendentes = await _perfilBancoRepository.listarPendentesDeSincronizacao();
    for (final perfil in pendentes) {
      try {
        final doc = colecao.doc(perfil.id);
        await doc.set({
          'nomeBanco': perfil.nomeBanco,
          'delimitador': perfil.delimitador,
          'codificacaoLatin1': perfil.codificacaoLatin1,
          'temCabecalho': perfil.temCabecalho,
          'formatoData': perfil.formatoData,
          'separadorDecimalVirgula': perfil.separadorDecimalVirgula,
          'mapeamentoColunas': perfil.mapeamentoColunas.map((k, v) => MapEntry(k.toString(), v.name)),
          'assinaturaCabecalho': perfil.assinaturaCabecalho,
        });
        await _perfilBancoRepository.confirmarSincronizacao(id: perfil.id, remoteId: doc.id);
      } catch (_) {}
    }

    final remotos = await colecao.get();
    for (final doc in remotos.docs) {
      try {
        final dados = doc.data();
        final mapeamentoRaw = (dados['mapeamentoColunas'] as Map?)?.cast<String, dynamic>() ?? {};
        await _perfilBancoRepository.aplicarRemoto(
          PerfilBanco(
            id: '',
            remoteId: doc.id,
            nomeBanco: dados['nomeBanco'] as String? ?? '',
            delimitador: dados['delimitador'] as String? ?? ',',
            codificacaoLatin1: dados['codificacaoLatin1'] as bool? ?? false,
            temCabecalho: dados['temCabecalho'] as bool? ?? true,
            formatoData: dados['formatoData'] as String? ?? 'dd/MM/yyyy',
            separadorDecimalVirgula: dados['separadorDecimalVirgula'] as bool? ?? true,
            mapeamentoColunas: mapeamentoRaw.map(
              (k, v) => MapEntry(int.parse(k), CampoColuna.values.byName(v as String)),
            ),
            assinaturaCabecalho: (dados['assinaturaCabecalho'] as List? ?? []).cast<String>(),
          ),
        );
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------
  // Rendas
  // ---------------------------------------------------------------------

  Future<void> _sincronizarRendas() async {
    final colecao = _colecao('rendas');

    final pendentes = await _rendaRepository.listarPendentesDeSincronizacao();
    for (final renda in pendentes) {
      try {
        final doc = colecao.doc(renda.id);
        await doc.set({
          'descricao': renda.descricao,
          'valor': renda.valor,
          'tipo': renda.tipo.name,
          'recorrencia': renda.recorrencia?.name,
          'dataRecebimento': Timestamp.fromDate(renda.dataRecebimento),
          'ativa': renda.ativa,
        });
        await _rendaRepository.confirmarSincronizacao(id: renda.id, remoteId: doc.id);
      } catch (_) {}
    }

    final remotos = await colecao.get();
    for (final doc in remotos.docs) {
      try {
        final dados = doc.data();
        final recorrenciaStr = dados['recorrencia'] as String?;
        await _rendaRepository.aplicarRemoto(
          Renda(
            id: '',
            remoteId: doc.id,
            descricao: dados['descricao'] as String? ?? '',
            valor: (dados['valor'] as num?)?.toDouble() ?? 0,
            tipo: TipoRenda.values.byName(dados['tipo'] as String? ?? 'variavel'),
            recorrencia: recorrenciaStr != null ? RecorrenciaRenda.values.byName(recorrenciaStr) : null,
            dataRecebimento: (dados['dataRecebimento'] as Timestamp?)?.toDate() ?? DateTime.now(),
            ativa: dados['ativa'] as bool? ?? true,
          ),
        );
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------
  // Metas
  // ---------------------------------------------------------------------

  Future<void> _sincronizarMetas() async {
    final colecao = _colecao('metas');

    final paraExcluir = await _metaRepository.listarPendentesDeExclusao();
    for (final meta in paraExcluir) {
      try {
        await colecao.doc(meta.remoteId).delete();
        await _metaRepository.confirmarExclusao(meta.id);
      } catch (_) {
        // mantém pendingDelete — a próxima rodada tenta de novo.
      }
    }

    final pendentes = await _metaRepository.listarPendentesDeSincronizacao();
    for (final meta in pendentes) {
      try {
        final doc = colecao.doc(meta.id);
        await doc.set({
          'nome': meta.nome,
          'valorAtual': meta.valorAtual,
          'valorAlvo': meta.valorAlvo,
          'prazo': Timestamp.fromDate(meta.prazo),
          'banco': meta.banco,
        });
        await _metaRepository.confirmarSincronizacao(id: meta.id, remoteId: doc.id);
      } catch (_) {}
    }

    final remotos = await colecao.get();
    for (final doc in remotos.docs) {
      try {
        final dados = doc.data();
        await _metaRepository.aplicarRemoto(
          Meta(
            id: '',
            remoteId: doc.id,
            nome: dados['nome'] as String? ?? '',
            valorAtual: (dados['valorAtual'] as num?)?.toDouble() ?? 0,
            valorAlvo: (dados['valorAlvo'] as num?)?.toDouble() ?? 0,
            prazo: (dados['prazo'] as Timestamp?)?.toDate() ?? DateTime.now(),
            banco: dados['banco'] as String?,
          ),
        );
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------
  // Parcelamentos
  // ---------------------------------------------------------------------

  /// O documento segue exatamente o formato validado por `firestore.rules`
  /// (datas como texto ISO, só as chaves permitidas).
  Future<void> _sincronizarParcelamentos() async {
    final colecao = _colecao('parcelamentos');

    final paraExcluir = await _parcelamentoRepository.listarPendentesDeExclusao();
    for (final parcelamento in paraExcluir) {
      try {
        await colecao.doc(parcelamento.remoteId).delete();
        await _parcelamentoRepository.confirmarExclusao(parcelamento.id);
      } catch (_) {
        // mantém pendingDelete — a próxima rodada tenta de novo.
      }
    }

    final pendentes = await _parcelamentoRepository.listarPendentesDeSincronizacao();
    for (final parcelamento in pendentes) {
      try {
        final doc = colecao.doc(parcelamento.id);
        await doc.set({
          'id': parcelamento.id,
          'transacaoOriginalId': parcelamento.transacaoOriginalId,
          'totalOriginal': parcelamento.totalOriginal,
          'numeroParcelas': parcelamento.numeroParcelas,
          'dataPrimeiraParc': parcelamento.dataPrimeiraParc.toIso8601String(),
          'updatedAt': parcelamento.updatedAt.toIso8601String(),
        });
        await _parcelamentoRepository.confirmarSincronizacao(id: parcelamento.id, remoteId: doc.id);
      } catch (_) {}
    }

    final remotos = await colecao.get();
    for (final doc in remotos.docs) {
      try {
        final dados = doc.data();
        await _parcelamentoRepository.aplicarRemoto(
          Parcelamento(
            id: dados['id'] as String? ?? doc.id,
            remoteId: doc.id,
            transacaoOriginalId: dados['transacaoOriginalId'] as String,
            totalOriginal: (dados['totalOriginal'] as num).toDouble(),
            numeroParcelas: (dados['numeroParcelas'] as num).toInt(),
            dataPrimeiraParc: DateTime.parse(dados['dataPrimeiraParc'] as String),
            updatedAt: DateTime.parse(dados['updatedAt'] as String),
          ),
        );
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------
  // Orçamento (limites por categoria)
  // ---------------------------------------------------------------------

  Future<void> _sincronizarOrcamentos() async {
    final colecao = _colecao('orcamentos');

    final paraExcluir = await _orcamentoRepository.listarPendentesDeExclusao();
    for (final orcamento in paraExcluir) {
      try {
        await colecao.doc(orcamento.remoteId).delete();
        await _orcamentoRepository.confirmarExclusao(orcamento.id);
      } catch (_) {
        // mantém pendingDelete — a próxima rodada tenta de novo.
      }
    }

    final pendentes = await _orcamentoRepository.listarPendentesDeSincronizacao();
    for (final orcamento in pendentes) {
      try {
        final doc = colecao.doc(orcamento.remoteId ?? orcamento.id);
        await doc.set({
          'categoria': orcamento.categoria,
          'limite': orcamento.limite,
        });
        await _orcamentoRepository.confirmarSincronizacao(id: orcamento.id, remoteId: doc.id);
      } catch (_) {}
    }

    final remotos = await colecao.get();
    for (final doc in remotos.docs) {
      try {
        final dados = doc.data();
        await _orcamentoRepository.aplicarRemoto(
          remoteId: doc.id,
          categoria: dados['categoria'] as String,
          limite: (dados['limite'] as num).toDouble(),
        );
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------
  // Contas a pagar
  // ---------------------------------------------------------------------

  Future<void> _sincronizarContas() async {
    final colecao = _colecao('contas');

    final paraExcluir = await _contaRepository.listarPendentesDeExclusao();
    for (final conta in paraExcluir) {
      try {
        await colecao.doc(conta.remoteId).delete();
        await _contaRepository.confirmarExclusao(conta.id);
      } catch (_) {
        // mantém pendingDelete — a próxima rodada tenta de novo.
      }
    }

    final pendentes = await _contaRepository.listarPendentesDeSincronizacao();
    for (final conta in pendentes) {
      try {
        final doc = colecao.doc(conta.remoteId ?? conta.id);
        await doc.set({
          'descricao': conta.descricao,
          'categoria': conta.categoria,
          'valor': conta.valor,
          'vencimento': Timestamp.fromDate(conta.vencimento),
          'diaBase': conta.diaBase,
          'recorrencia': conta.recorrencia.name,
          'paga': conta.paga,
          'dataPagamento': conta.dataPagamento == null ? null : Timestamp.fromDate(conta.dataPagamento!),
          'valorPago': conta.valorPago,
          'diasAntesLembrete': conta.diasAntesLembrete,
          'transacaoId': conta.transacaoId,
        });
        await _contaRepository.confirmarSincronizacao(id: conta.id, remoteId: doc.id);
      } catch (_) {}
    }

    final remotos = await colecao.get();
    for (final doc in remotos.docs) {
      try {
        final dados = doc.data();
        final vencimento = (dados['vencimento'] as Timestamp).toDate();
        await _contaRepository.aplicarRemoto(
          ContaAPagar(
            id: '',
            remoteId: doc.id,
            descricao: dados['descricao'] as String,
            categoria: dados['categoria'] as String? ?? '',
            valor: (dados['valor'] as num).toDouble(),
            vencimento: vencimento,
            diaBase: (dados['diaBase'] as num?)?.toInt() ?? vencimento.day,
            recorrencia: RecorrenciaConta.values.asNameMap()[dados['recorrencia']] ?? RecorrenciaConta.nenhuma,
            paga: dados['paga'] as bool? ?? false,
            dataPagamento: (dados['dataPagamento'] as Timestamp?)?.toDate(),
            valorPago: (dados['valorPago'] as num?)?.toDouble(),
            diasAntesLembrete: (dados['diasAntesLembrete'] as num?)?.toInt() ?? 1,
            transacaoId: dados['transacaoId'] as String?,
          ),
        );
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------
  // Categorias personalizadas (documento com id = nome codificado)
  // ---------------------------------------------------------------------

  /// O nome da categoria vira o id do documento (sem `/`, que o Firestore não aceita).
  static String idDocCategoria(String nome) => Uri.encodeComponent(nome);

  Future<void> _sincronizarCategorias() async {
    final colecao = _colecao('categorias');

    for (final nome in await _categoriaRepository.listarPendentesDeExclusao()) {
      try {
        await colecao.doc(idDocCategoria(nome)).delete();
        await _categoriaRepository.confirmarExclusao(nome);
      } catch (_) {
        // mantém a marca de exclusão — a próxima rodada tenta de novo.
      }
    }

    for (final nome in await _categoriaRepository.listarPendentesDeSincronizacao()) {
      try {
        await colecao.doc(idDocCategoria(nome)).set({'nome': nome});
        await _categoriaRepository.confirmarSincronizacao(nome);
      } catch (_) {}
    }

    final remotos = await colecao.get();
    final nomes = <String>{};
    for (final doc in remotos.docs) {
      try {
        final nome = doc.data()['nome'] as String;
        nomes.add(nome);
        await _categoriaRepository.aplicarRemoto(nome);
      } catch (_) {}
    }
    await _categoriaRepository.removerAusentesNoRemoto(nomes);
  }

  // ---------------------------------------------------------------------
  // Investimentos manuais
  // ---------------------------------------------------------------------

  Future<void> _sincronizarInvestimentos() async {
    final colecao = _colecao('investimentos');

    for (final id in await _investimentoRepository.listarPendentesDeExclusao()) {
      try {
        await colecao.doc(id).delete();
        await _investimentoRepository.confirmarExclusao(id);
      } catch (_) {}
    }

    for (final i in await _investimentoRepository.listarPendentesDeSincronizacao()) {
      try {
        await colecao.doc(i.id).set({
          'nome': i.nome,
          'tipo': i.tipo.name,
          'valorInvestido': i.valorInvestido,
          'valorAtual': i.valorAtual,
          'dataAplicacao': Timestamp.fromDate(i.dataAplicacao),
          'observacao': i.observacao,
        });
        await _investimentoRepository.confirmarSincronizacao(i.id);
      } catch (_) {}
    }

    final remotos = await colecao.get();
    final ids = <String>{};
    for (final doc in remotos.docs) {
      try {
        final d = doc.data();
        ids.add(doc.id);
        await _investimentoRepository.aplicarRemoto(
          Investimento(
            id: doc.id,
            nome: d['nome'] as String,
            tipo: TipoInvestimento.deNome(d['tipo'] as String? ?? ''),
            valorInvestido: (d['valorInvestido'] as num).toDouble(),
            valorAtual: (d['valorAtual'] as num).toDouble(),
            dataAplicacao: (d['dataAplicacao'] as Timestamp).toDate(),
            observacao: d['observacao'] as String? ?? '',
          ),
        );
      } catch (_) {}
    }
    await _investimentoRepository.removerAusentesNoRemoto(ids);
  }

  // ---------------------------------------------------------------------
  // Lembretes personalizados
  // ---------------------------------------------------------------------

  Future<void> _sincronizarLembretes() async {
    final colecao = _colecao('lembretes');

    for (final id in await _lembreteRepository.listarPendentesDeExclusao()) {
      try {
        await colecao.doc(id).delete();
        await _lembreteRepository.confirmarExclusao(id);
      } catch (_) {}
    }

    for (final l in await _lembreteRepository.listarPendentesDeSincronizacao()) {
      try {
        await colecao.doc(l.id).set({
          'titulo': l.titulo,
          'tipo': l.tipo.name,
          'dia': l.dia,
          'ativo': l.ativo,
        });
        await _lembreteRepository.confirmarSincronizacao(l.id);
      } catch (_) {}
    }

    final remotos = await colecao.get();
    final ids = <String>{};
    for (final doc in remotos.docs) {
      try {
        final d = doc.data();
        ids.add(doc.id);
        await _lembreteRepository.aplicarRemoto(
          LembretePersonalizado(
            id: doc.id,
            titulo: d['titulo'] as String,
            tipo: TipoLembrete.deNome(d['tipo'] as String? ?? ''),
            dia: (d['dia'] as num).toInt(),
            ativo: d['ativo'] as bool? ?? true,
          ),
        );
      } catch (_) {}
    }
    await _lembreteRepository.removerAusentesNoRemoto(ids);
  }

  // ---------------------------------------------------------------------
  // Cartões de crédito
  // ---------------------------------------------------------------------

  Future<void> _sincronizarCartoes() async {
    final colecao = _colecao('cartoes');

    for (final id in await _cartaoRepository.cartoesPendentesDeExclusao()) {
      try {
        await colecao.doc(id).delete();
        await _cartaoRepository.confirmarExclusaoCartao(id);
      } catch (_) {}
    }

    for (final c in await _cartaoRepository.cartoesPendentesDeSincronizacao()) {
      try {
        await colecao.doc(c.id).set({
          'nome': c.nome,
          'diaFechamento': c.diaFechamento,
          'diaVencimento': c.diaVencimento,
          'limite': c.limite,
        });
        await _cartaoRepository.confirmarCartao(c.id);
      } catch (_) {}
    }

    final remotos = await colecao.get();
    final ids = <String>{};
    for (final doc in remotos.docs) {
      try {
        final d = doc.data();
        ids.add(doc.id);
        await _cartaoRepository.aplicarCartaoRemoto(
          Cartao(
            id: doc.id,
            nome: d['nome'] as String,
            diaFechamento: (d['diaFechamento'] as num).toInt(),
            diaVencimento: (d['diaVencimento'] as num).toInt(),
            limite: (d['limite'] as num?)?.toDouble(),
          ),
        );
      } catch (_) {}
    }
    await _cartaoRepository.removerCartoesAusentes(ids);
  }

  // ---------------------------------------------------------------------
  // Faturas pagas
  // ---------------------------------------------------------------------

  /// O id do documento é o da fatura ("cartao|ano-mes"): `|` é aceito pelo Firestore.
  Future<void> _sincronizarFaturasPagas() async {
    final colecao = _colecao('faturas_pagas');

    for (final id in await _cartaoRepository.pagamentosPendentesDeExclusao()) {
      try {
        await colecao.doc(id).delete();
        await _cartaoRepository.confirmarExclusaoPagamento(id);
      } catch (_) {}
    }

    for (final p in await _cartaoRepository.pagamentosPendentesDeSincronizacao()) {
      try {
        await colecao.doc(p.id).set({
          'cartaoId': p.cartaoId,
          'ano': p.ano,
          'mes': p.mes,
          'valor': p.valor,
          'dataPagamento': Timestamp.fromDate(p.dataPagamento),
        });
        await _cartaoRepository.confirmarPagamento(p.id);
      } catch (_) {}
    }

    final remotos = await colecao.get();
    final ids = <String>{};
    for (final doc in remotos.docs) {
      try {
        final d = doc.data();
        ids.add(doc.id);
        await _cartaoRepository.aplicarPagamentoRemoto(
          FaturaPaga(
            cartaoId: d['cartaoId'] as String,
            ano: (d['ano'] as num).toInt(),
            mes: (d['mes'] as num).toInt(),
            valor: (d['valor'] as num).toDouble(),
            dataPagamento: (d['dataPagamento'] as Timestamp).toDate(),
          ),
        );
      } catch (_) {}
    }
    await _cartaoRepository.removerPagamentosAusentes(ids);
  }
}
