import 'package:teofinance/core/services/notificacao_service.dart';
import 'package:teofinance/core/utils/date_label.dart';

/// Dia do mês padrão do aviso para enviar o extrato.
const kDiaPadraoLembreteExtrato = 5;

/// Ids fixos (1..N) das notificações do extrato: reagendar substitui as antigas.
const kIdBaseLembreteExtrato = 1;

/// Quantos meses à frente ficam agendados (o app reagenda a cada abertura).
const kMesesAgendadosExtrato = 3;

/// Dia válido para o aviso (1–28, para existir em todo mês).
int diaValidoExtrato(int dia) => dia.clamp(1, 28);

/// Próximas ocorrências do aviso "envie o extrato do mês anterior": todo
/// [dia] do mês, às [hora] horas. Ocorrências que já passaram ficam de fora.
List<NotificacaoAgendada> planejarLembretesExtrato({
  required DateTime agora,
  required int dia,
  required int hora,
}) {
  final diaOk = diaValidoExtrato(dia);
  final lista = <NotificacaoAgendada>[];

  for (var i = 0; i <= kMesesAgendadosExtrato; i++) {
    final base = DateTime(agora.year, agora.month + i);
    final quando = DateTime(base.year, base.month, diaOk, hora);
    if (!quando.isAfter(agora)) continue;

    final anterior = DateTime(base.year, base.month - 1);
    lista.add(
      NotificacaoAgendada(
        id: kIdBaseLembreteExtrato + lista.length,
        quando: quando,
        titulo: 'Hora de enviar o extrato',
        corpo:
            'Envie o extrato de ${kMesesPorExtenso[anterior.month - 1]} para comparar com seus lançamentos.',
      ),
    );
  }
  return lista.take(kMesesAgendadosExtrato).toList();
}
