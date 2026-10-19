import 'package:teofinance/core/services/notificacao_service.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/services/planejar_lembretes.dart';

/// Mantém os lembretes do aparelho iguais às contas em aberto. É idempotente:
/// chamar de novo com os mesmos dados deixa tudo como está.
class ReagendarLembretesUseCase {
  ReagendarLembretesUseCase(this._notificacoes, {DateTime Function() agora = DateTime.now}) : _agora = agora;

  final NotificacaoService _notificacoes;
  final DateTime Function() _agora;

  /// Com lembretes desligados, ou sem permissão do sistema, cancela tudo e não
  /// agenda nada. Devolve quantos lembretes ficaram agendados.
  Future<int> call({
    required List<ContaAPagar> contas,
    required bool ativo,
    required int hora,
  }) async {
    try {
      if (!ativo || !await _notificacoes.permissaoConcedida()) {
        await _notificacoes.cancelarTudo();
        return 0;
      }
      final lembretes = planejarLembretes(contas, agora: _agora(), hora: hora);
      await _notificacoes.reagendarTudo(lembretes);
      return lembretes.length;
    } catch (_) {
      // Falha de plugin nunca pode derrubar o app: o usuário só fica sem lembrete.
      return 0;
    }
  }
}
