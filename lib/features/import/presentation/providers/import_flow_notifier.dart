import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../reconciliation/presentation/providers/reconciliation_providers.dart';
import '../../domain/entities/campo_coluna.dart';
import '../../domain/entities/modelo_partida_banco.dart';
import '../../domain/entities/perfil_banco.dart';
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

    final resultado = await ref.read(importarExtratoUseCaseProvider).analisar(bytes);
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

  /// Persiste as transações revisadas localmente (`pendingSync = true`),
  /// para `features/sync/` enviar ao Firestore quando houver conexão.
  ///
  /// TODO(fase-1): mover para um `TransacaoRepository` dedicado quando
  /// `features/transacao/` existir — por ora grava direto na tabela do
  /// `core/database` para fechar o fluxo ponta a ponta do MVP.
  Future<void> confirmarImportacao() async {
    final db = ref.read(appDatabaseProvider);
    await db.batch((batch) {
      batch.insertAll(
        db.transactionsTable,
        state.transacoes.map((t) {
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

    state = state.copyWith(etapa: ImportEtapa.concluido);
  }

  /// Guarda o extrato como linhas separadas (sem criar transações), para
  /// comparar com os lançamentos manuais em `features/reconciliation/`.
  Future<void> confirmarParaReconciliacao() async {
    state = state.copyWith(carregando: true, limparErro: true);

    final resultado = await ref.read(reconciliationRepositoryProvider).importarExtrato(
          importId: _uuid.v4(),
          linhas: state.transacoes
              .map((t) => {
                    'descricao': t.descricao,
                    'valor': t.valor.abs(),
                    'data': t.data.toIso8601String(),
                    'tipo': t.valor < 0 ? 'D' : 'C',
                    'nomeBancoOriginal': state.perfilUsado?.nomeBanco ?? '',
                  })
              .toList(),
        );

    resultado.match(
      (falha) => state = state.copyWith(carregando: false, erro: falha.message),
      (_) => state = state.copyWith(
        carregando: false,
        etapa: ImportEtapa.concluido,
        paraReconciliacao: true,
      ),
    );
  }

  void reiniciar() => state = const ImportFlowState();
}

final importFlowProvider = NotifierProvider<ImportFlowNotifier, ImportFlowState>(
  ImportFlowNotifier.new,
);
