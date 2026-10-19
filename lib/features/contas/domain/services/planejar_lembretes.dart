import 'package:teofinance/core/services/notificacao_service.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';

/// Android limita as notificações agendadas pendentes; contas além disso ficam
/// para a próxima reagendada (o app reagenda tudo a cada abertura).
const kMaxLembretesAgendados = 60;

/// Id estável (FNV-1a de 32 bits, positivo) de um lembrete de conta. Não usa
/// `String.hashCode`, que não é garantido entre execuções.
int idDoLembrete(String contaId, {required bool noDia}) {
  var h = 0x811c9dc5;
  for (final unidade in '$contaId|${noDia ? 'dia' : 'antes'}'.codeUnits) {
    h ^= unidade;
    h = (h * 0x01000193) & 0x7fffffff;
  }
  return h;
}

String _quando(int dias) => switch (dias) {
      0 => 'hoje',
      1 => 'amanhã',
      _ => 'em $dias dias',
    };

/// Quais notificações agendar: para cada conta em aberto, o lembrete
/// [ContaAPagar.diasAntesLembrete] dias antes e, se for antes do vencimento,
/// outro no dia, ambos às [hora] horas. Horários que já passaram ficam de fora.
List<NotificacaoAgendada> planejarLembretes(
  List<ContaAPagar> contas, {
  required DateTime agora,
  required int hora,
}) {
  final lista = <NotificacaoAgendada>[];

  for (final c in contas) {
    if (c.paga) continue;
    final venc = soDia(c.vencimento);
    final valor = formatCurrency(c.valor);

    final antes = c.diaDoLembrete;
    if (c.diasAntesLembrete > 0) {
      lista.add(NotificacaoAgendada(
        id: idDoLembrete(c.id, noDia: false),
        quando: DateTime(antes.year, antes.month, antes.day, hora),
        titulo: '${c.descricao} vence ${_quando(c.diasAntesLembrete)}',
        corpo: 'Vencimento em ${venc.day.toString().padLeft(2, '0')}/${venc.month.toString().padLeft(2, '0')} · $valor',
      ));
    }
    lista.add(NotificacaoAgendada(
      id: idDoLembrete(c.id, noDia: true),
      quando: DateTime(venc.year, venc.month, venc.day, hora),
      titulo: '${c.descricao} vence hoje',
      corpo: 'Valor esperado: $valor',
    ));
  }

  final futuras = lista.where((l) => l.quando.isAfter(agora)).toList()
    ..sort((a, b) => a.quando.compareTo(b.quando));
  return futuras.take(kMaxLembretesAgendados).toList();
}
