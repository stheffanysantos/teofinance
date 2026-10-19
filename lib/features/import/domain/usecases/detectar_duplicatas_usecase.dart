import 'package:teofinance/features/import/domain/entities/transacao_importada.dart';
import 'package:teofinance/features/import/domain/services/marcar_duplicatas.dart';
import 'package:teofinance/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';

/// Para onde o extrato importado vai: vira transações, ou é guardado como
/// linhas para a reconciliação. Cada destino compara com um acervo diferente.
enum DestinoImportacao { transacoes, reconciliacao }

/// Aponta quais linhas do arquivo já foram importadas antes.
///
/// - Para [DestinoImportacao.transacoes], compara com as transações existentes.
/// - Para [DestinoImportacao.reconciliacao], compara só com linhas de extrato já
///   importadas. Comparar com as transações ali seria errado: casar o extrato
///   com os lançamentos é justamente o objetivo da reconciliação.
class DetectarDuplicatasUseCase {
  DetectarDuplicatasUseCase({
    required TransacaoRepository transacoes,
    required ReconciliationRepository reconciliacao,
  })  : _transacoes = transacoes,
        _reconciliacao = reconciliacao;

  final TransacaoRepository _transacoes;
  final ReconciliationRepository _reconciliacao;

  /// Se não for possível ler o acervo existente, devolve vazio: não conseguir
  /// checar nunca pode impedir o usuário de importar.
  Future<Set<int>> call({
    required List<TransacaoImportada> importadas,
    required DestinoImportacao destino,
  }) async {
    try {
      final existentes = switch (destino) {
        DestinoImportacao.transacoes => (await _transacoes.observarTodas().first)
            .map((t) => chaveLancamento(t.data, t.valorCobrado, t.descricao)),
        DestinoImportacao.reconciliacao => (await _reconciliacao.listarLinhasImportadas())
            .map((l) => chaveLancamento(l.data, l.valorAsTransacao, l.descricao)),
      };
      return indicesDuplicados(importadas: importadas, chavesExistentes: existentes.toList());
    } catch (_) {
      return const {};
    }
  }
}
