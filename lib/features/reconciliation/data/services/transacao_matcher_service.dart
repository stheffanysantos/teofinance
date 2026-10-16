import '../../domain/entities/extrato_linha.dart';
import '../../../transacao/domain/entities/transacao.dart';

/// Serviço que implementa o algoritmo de matching entre transações e linhas do extrato.
/// Estratégia: valor + data (simples, mas eficaz).
class TransacaoMatcherService {
  /// Encontra possíveis matches entre transações e linhas do extrato.
  /// Retorna: (transacao, linhaExtrato, confidence)
  ///
  /// Regras:
  /// - Valor exato + data ±2 dias = 100% confidence
  /// - Valor ±5% + data ±3 dias = 70-90% confidence (candidato)
  /// - Sem correspondência = não aparece
  List<(Transacao, ExtratoLinha, double)> encontrarMatches({
    required List<Transacao> transacoes,
    required List<ExtratoLinha> linhasExtrato,
  }) {
    final matches = <(Transacao, ExtratoLinha, double)>[];

    for (final txn in transacoes) {
      for (final linha in linhasExtrato) {
        final confidence = _calcularConfianca(txn, linha);

        if (confidence >= 0.7) {
          matches.add((txn, linha, confidence));
        }
      }
    }

    // Ordenar por confiança decrescente
    matches.sort((a, b) => b.$3.compareTo(a.$3));

    return matches;
  }

  /// Calcula confiança do match (0.0–1.0): até 0.5 pelo valor e 0.5 pela data.
  double _calcularConfianca(Transacao txn, ExtratoLinha linha) {
    double score = 0.0;

    // O banco mostra o total cobrado, não a parte do usuário numa compra dividida.
    final valorTxn = txn.valorCobrado;
    final diferencaValor = (valorTxn - linha.valorAsTransacao).abs();
    final base = valorTxn.abs();
    final percentualDiferenca = base == 0 ? (diferencaValor == 0 ? 0.0 : 1.0) : diferencaValor / base;

    if (percentualDiferenca == 0.0) {
      score += 0.5;
    } else if (percentualDiferenca <= 0.05) {
      score += 0.5 * (1 - percentualDiferenca / 0.05);
    }

    final diferencaDias = DateTime(txn.data.year, txn.data.month, txn.data.day)
        .difference(DateTime(linha.data.year, linha.data.month, linha.data.day))
        .inDays
        .abs();

    if (diferencaDias == 0) {
      score += 0.5;
    } else if (diferencaDias == 1) {
      score += 0.45;
    } else if (diferencaDias == 2) {
      score += 0.4;
    } else if (diferencaDias == 3) {
      score += 0.25;
    }

    return score.clamp(0.0, 1.0);
  }
}
