import 'package:cloud_firestore/cloud_firestore.dart';

import '../../budget/domain/repositories/orcamento_repository.dart';
import '../../import/domain/entities/campo_coluna.dart';
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
  }) : _firestore = firestore,
       _uid = uid,
       _transacaoRepository = transacaoRepository,
       _perfilBancoRepository = perfilBancoRepository,
       _rendaRepository = rendaRepository,
       _metaRepository = metaRepository,
       _parcelamentoRepository = parcelamentoRepository,
       _orcamentoRepository = orcamentoRepository;

  final FirebaseFirestore _firestore;
  final String _uid;
  final TransacaoRepository _transacaoRepository;
  final PerfilBancoRepository _perfilBancoRepository;
  final RendaRepository _rendaRepository;
  final MetaRepository _metaRepository;
  final ParcelamentoRepository _parcelamentoRepository;
  final OrcamentoRepository _orcamentoRepository;

  CollectionReference<Map<String, dynamic>> _colecao(String nome) {
    return _firestore.collection('users').doc(_uid).collection(nome);
  }

  Future<void> sincronizarTudo() async {
    // Cada entidade roda isoladamente — uma falhar não impede as outras.
    // Parcelamentos antes das transações: as parcelas apontam para eles.
    await _tentar(_sincronizarParcelamentos);
    await _tentar(_sincronizarTransacoes);
    await _tentar(_sincronizarPerfisBanco);
    await _tentar(_sincronizarRendas);
    await _tentar(_sincronizarMetas);
    await _tentar(_sincronizarOrcamentos);
  }

  Future<void> _tentar(Future<void> Function() sincronizar) async {
    try {
      await sincronizar();
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
}
