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
      // Skip se já foi reconciliada
      if (txn.reconciliationStatus == 'reconciliada') {
        continue;
      }

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

  /// Calcula confiança do match (0.0–1.0).
  /// 50% valor, 50% data.
  double _calcularConfianca(Transacao txn, ExtratoLinha linha) {
    double score = 0.0;

    // 1. Valor (50%)
    final diferencaValor = (txn.valorContabilizado - linha.valorAsTransacao).abs();
    final percentualDiferenca = diferencaValor / txn.valorContabilizado.abs();

    if (percentualDiferenca == 0.0) {
      score += 0.5; // Valor exato
    } else if (percentualDiferenca <= 0.05) {
      score += 0.5 * (1 - percentualDiferenca / 0.05); // Até 5%
    }

    // 2. Data (50%)
    final diferencaDias = txn.data.difference(linha.data).inDays.abs();

    if (diferencaDias == 0) {
      score += 0.5; // Mesma data
    } else if (diferencaDias <= 2) {
      score += 0.5 * (1 - diferencaDias / 2);
    } else if (diferencaDias <= 3) {
      score += 0.25; // Tolerância maior = menos confiança
    }

    return score.clamp(0.0, 1.0);
  }
}
