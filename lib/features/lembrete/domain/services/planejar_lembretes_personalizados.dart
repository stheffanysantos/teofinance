import 'package:teofinance/core/services/notificacao_service.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';

const kMesesAgendadosPersonalizados = 3;

/// Id estável (FNV-1a de 31 bits) de uma notificação de lembrete personalizado.
/// Não usa `String.hashCode`, que não é garantido entre execuções. Começa em
/// 1.000.000 para nunca cair nos ids fixos do extrato (1..3).
int idDoLembretePersonalizado(String lembreteId, int ocorrencia) {
  var h = 0x811c9dc5;
  for (final unidade in '$lembreteId|$ocorrencia'.codeUnits) {
    h ^= unidade;
    h = (h * 0x01000193) & 0x7fffffff;
  }
  return 1000000 + h % 2000000000;
}

int _ultimoDiaDoMes(int ano, int mes) => DateTime(ano, mes + 1, 0).day;

/// Próximas ocorrências de cada lembrete ativo, às [hora] horas. Ocorrências
/// que já passaram ficam de fora.
List<NotificacaoAgendada> planejarLembretesPersonalizados(
  List<LembretePersonalizado> lembretes, {
  required DateTime agora,
  required int hora,
}) {
  final lista = <NotificacaoAgendada>[];

  for (final l in lembretes) {
    if (!l.ativo) continue;
    var ocorrencia = 0;
    for (var i = 0; i <= kMesesAgendadosPersonalizados && ocorrencia < kMesesAgendadosPersonalizados; i++) {
      final base = DateTime(agora.year, agora.month + i);
      final dia = l.dia.clamp(1, _ultimoDiaDoMes(base.year, base.month));
      final quando = DateTime(base.year, base.month, dia, hora);
      if (!quando.isAfter(agora)) continue;
      lista.add(NotificacaoAgendada(
        id: idDoLembretePersonalizado(l.id, ocorrencia),
        quando: quando,
        titulo: l.titulo,
        corpo: l.tipo.mensagem,
      ));
      ocorrencia++;
    }
  }
  return lista;
}
