import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../reconciliation/presentation/providers/reconciliation_providers.dart';
import '../../domain/entities/campo_coluna.dart';
import '../../domain/entities/formato_extrato.dart';
import '../../domain/entities/modelo_partida_banco.dart';
import '../../domain/entities/perfil_banco.dart';
import '../../domain/entities/transacao_importada.dart';
import '../../domain/usecases/detectar_duplicatas_usecase.dart';
import 'import_flow_state.dart';
import 'import_providers.dart';

/// Orquestra a UI dos passos 2-7 do fluxo de importação (ver
/// `.claude/docs/IMPORT_FLOW.md`); a lógica de negócio em si mora nos
/// usecases/repository — este Notifier só traduz estado para a tela.
class ImportFlowNotifier extends Notifier<ImportFlowState> {
  static const _uuid = Uuid();

  @override
  ImportFlowState build() => const ImportFlowState();

  Future<void> analisarArquivo({required Uint8List bytes, required String nomeArquivo}) async {
    state = state.copyWith(
      carregando: true,
      limparErro: true,
      bytes: bytes,
      nomeArquivo: nomeArquivo,
    );

    final usecase = ref.read(importarExtratoUseCaseProvider);

    // OFX já traz cada campo identificado: vai direto para a revisão, sem
    // mapear colunas nem salvar Perfil de Banco.
    if (usecase.detectarFormato(bytes) == FormatoExtrato.ofx) {
      final ofx = await usecase.importarOfx(bytes);
      ofx.match(
        (falha) => state = state.copyWith(carregando: false, erro: falha.message),
        (extrato) => state = state.copyWith(
          carregando: false,
          formato: FormatoExtrato.ofx,
          etapa: ImportEtapa.revisando,
          transacoes: extrato.transacoes,
          instituicao: extrato.instituicao,
        ),
      );
      return;
    }

    final resultado = await usecase.analisar(bytes);
    resultado.match(
      (falha) => state = state.copyWith(carregando: false, erro: falha.message),
      (preview) {
        final perfilCompativel = preview.perfilCompativel;
        state = state.copyWith(
          carregando: false,
          preview: preview,
          etapa: ImportEtapa.mapeandoColunas,
          mapeamentoRascunho: perfilCompativel?.mapeamentoColunas ?? const {},
          nomePerfil: perfilCompativel?.nomeBanco ?? '',
          formatoData: perfilCompativel?.formatoData ?? 'dd/MM/yyyy',
          separadorDecimalVirgula: perfilCompativel?.separadorDecimalVirgula ?? true,
        );
      },
    );
  }

  /// Pré-preenche o rascunho de mapeamento com um modelo de partida
  /// (Nubank/BB/...) — o usuário ainda confirma/ajusta antes de salvar.
  void aplicarModeloPartida(ModeloPartidaBanco modelo) {
    state = state.copyWith(
      nomePerfil: modelo.nomeBanco,
      mapeamentoRascunho: modelo.mapeamentoColunas,
      formatoData: modelo.formatoData,
      separadorDecimalVirgula: modelo.separadorDecimalVirgula,
    );
  }

  void definirNomePerfil(String nome) => state = state.copyWith(nomePerfil: nome);

  void definirCampoColuna(int indiceColuna, CampoColuna campo) {
    state = state.copyWith(
      mapeamentoRascunho: {...state.mapeamentoRascunho, indiceColuna: campo},
    );
  }

  void definirFormatoData(String formato) => state = state.copyWith(formatoData: formato);

  void definirSeparadorDecimal(bool virgula) =>
      state = state.copyWith(separadorDecimalVirgula: virgula);

  Future<void> confirmarMapeamentoEImportar() async {
    final preview = state.preview;
    final bytes = state.bytes;
    if (preview == null || bytes == null) return;

    state = state.copyWith(carregando: true, limparErro: true);

    final perfil = PerfilBanco(
      id: '',
      nomeBanco: state.nomePerfil.trim().isEmpty ? 'Perfil sem nome' : state.nomePerfil.trim(),
      delimitador: preview.delimitador,
      codificacaoLatin1: preview.codificacaoLatin1,
      temCabecalho: preview.temCabecalho,
      formatoData: state.formatoData,
      separadorDecimalVirgula: state.separadorDecimalVirgula,
      mapeamentoColunas: state.mapeamentoRascunho,
      assinaturaCabecalho: preview.cabecalho,
    );

    final salvo = await ref.read(salvarPerfilBancoUseCaseProvider).call(perfil);
    final perfilFinal = salvo.match((falha) => null, (p) => p);
    if (perfilFinal == null) {
      state = state.copyWith(
        carregando: false,
        erro: salvo.match((falha) => falha.message, (_) => null),
      );
      return;
    }

    final resultado = await ref
        .read(importarExtratoUseCaseProvider)
        .importar(bytes: bytes, perfil: perfilFinal);

    resultado.match(
      (falha) => state = state.copyWith(carregando: false, erro: falha.message),
      (transacoes) => state = state.copyWith(
        carregando: false,
        etapa: ImportEtapa.revisando,
        transacoes: transacoes,
        perfilUsado: perfilFinal,
      ),
    );
  }

  /// Quantas linhas do arquivo já foram importadas antes para o [destino].
  /// A tela usa isto para perguntar antes de duplicar.
  Future<int> contarDuplicadas(DestinoImportacao destino) async {
    final duplicadas = await ref.read(detectarDuplicatasUseCaseProvider)(
      importadas: state.transacoes,
      destino: destino,
    );
    return duplicadas.length;
  }

  /// Linhas que seguem para o [destino]: todas, ou só as novas.
  Future<List<TransacaoImportada>> _paraConfirmar(DestinoImportacao destino, {required bool pularDuplicadas}) async {
    if (!pularDuplicadas) return state.transacoes;

    final duplicadas = await ref.read(detectarDuplicatasUseCaseProvider)(
      importadas: state.transacoes,
      destino: destino,
    );
    return [
      for (var i = 0; i < state.transacoes.length; i++)
        if (!duplicadas.contains(i)) state.transacoes[i],
    ];
  }

  /// Persiste as transações revisadas localmente (`pendingSync = true`),
  /// para `features/sync/` enviar ao Firestore quando houver conexão.
  ///
  /// TODO(fase-1): mover para um `TransacaoRepository` dedicado quando
  /// `features/transacao/` existir — por ora grava direto na tabela do
  /// `core/database` para fechar o fluxo ponta a ponta do MVP.
  Future<void> confirmarImportacao({bool pularDuplicadas = false}) async {
    final aImportar = await _paraConfirmar(DestinoImportacao.transacoes, pularDuplicadas: pularDuplicadas);
    final db = ref.read(appDatabaseProvider);
    await db.batch((batch) {
      batch.insertAll(
        db.transactionsTable,
        aImportar.map((t) {
          return TransactionsTableCompanion.insert(
            id: _uuid.v4(),
            name: t.descricao,
            category: (t.categoria?.trim().isEmpty ?? true) ? '' : t.categoria!.trim(),
            value: t.valor,
            occurredAt: t.data,
            needsCategory: Value(t.precisaCategoria),
          );
        }).toList(),
      );
    });

    state = state.copyWith(etapa: ImportEtapa.concluido, transacoes: aImportar);
  }

  /// Guarda o extrato como linhas separadas (sem criar transações), para
  /// comparar com os lançamentos manuais em `features/reconciliation/`.
  Future<void> confirmarParaReconciliacao({bool pularDuplicadas = false}) async {
    state = state.copyWith(carregando: true, limparErro: true);

    final aImportar = await _paraConfirmar(DestinoImportacao.reconciliacao, pularDuplicadas: pularDuplicadas);
    final resultado = await ref.read(reconciliationRepositoryProvider).importarExtrato(
          importId: _uuid.v4(),
          linhas: aImportar
              .map((t) => {
                    'descricao': t.descricao,
                    'valor': t.valor.abs(),
                    'data': t.data.toIso8601String(),
                    'tipo': t.valor < 0 ? 'D' : 'C',
                    'nomeBancoOriginal': state.perfilUsado?.nomeBanco ?? state.instituicao ?? '',
                  })
              .toList(),
        );

    resultado.match(
      (falha) => state = state.copyWith(carregando: false, erro: falha.message),
      (_) => state = state.copyWith(
        carregando: false,
        etapa: ImportEtapa.concluido,
        paraReconciliacao: true,
        transacoes: aImportar,
      ),
    );
  }

  void reiniciar() => state = const ImportFlowState();
}

final importFlowProvider = NotifierProvider<ImportFlowNotifier, ImportFlowState>(
  ImportFlowNotifier.new,
);
