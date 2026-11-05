import 'package:teofinance/core/services/notificacao_service.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';

/// Faixas de uso do limite em que o usuário é avisado.
const kNivelAtencaoOrcamento = 80;
const kNivelEstouroOrcamento = 100;

/// Nível alcançado por um envelope: 0 (nenhum), 80 ou 100.
int nivelDoEnvelope(EnvelopeOrcamento e) {
  if (e.limite <= 0) return 0;
  if (e.gasto >= e.limite) return kNivelEstouroOrcamento;
  if (e.gasto >= e.limite * kNivelAtencaoOrcamento / 100) return kNivelAtencaoOrcamento;
  return 0;
}

/// Avisa (notificação local) quando uma categoria chega a 80% do limite do mês
/// e quando o estoura. Cada faixa é avisada uma vez por categoria e por mês:
/// [avisados] (categoria → maior faixa já avisada) é o que evita repetir.
class AvisarLimiteOrcamentoUseCase {
  AvisarLimiteOrcamentoUseCase(this._notificacoes);

  final NotificacaoService _notificacoes;

  /// Devolve o novo mapa de avisados para o chamador guardar.
  Future<Map<String, int>> call({
    required ResumoOrcamento resumo,
    required Map<String, int> avisados,
  }) async {
    final novos = {...avisados};
    for (final e in resumo.envelopes) {
      final nivel = nivelDoEnvelope(e);
      if (nivel == 0 || nivel <= (avisados[e.categoria] ?? 0)) continue;

      final estourou = nivel == kNivelEstouroOrcamento;
      await _notificacoes.mostrarAgora(
        titulo: estourou ? 'Orçamento de ${e.categoria} estourou' : 'Orçamento de ${e.categoria} quase no limite',
        corpo: estourou
            ? 'Você gastou ${formatCurrency(e.gasto)} de ${formatCurrency(e.limite)} neste mês.'
            : 'Você já usou ${(e.proporcao * 100).round()}% do limite: ${formatCurrency(e.gasto)} de ${formatCurrency(e.limite)}.',
      );
      novos[e.categoria] = nivel;
    }
    return novos;
  }
}
