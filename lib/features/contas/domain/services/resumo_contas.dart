import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';

/// Quanto há para pagar, só com contas ainda não pagas.
class ResumoContas {
  const ResumoContas({
    required this.atrasadas,
    required this.valorAtrasadas,
    required this.aVencerEm7Dias,
    required this.valorAVencerEm7Dias,
    required this.pendentesNoMes,
    required this.valorPendenteNoMes,
  });

  final int atrasadas;
  final double valorAtrasadas;

  /// Vencem de hoje até daqui a 7 dias (inclusive).
  final int aVencerEm7Dias;
  final double valorAVencerEm7Dias;

  /// Não pagas com vencimento no mês corrente.
  final int pendentesNoMes;
  final double valorPendenteNoMes;

  bool get temAlgoUrgente => atrasadas > 0 || aVencerEm7Dias > 0;
}

ResumoContas resumirContas(List<ContaAPagar> contas, {required DateTime hoje}) {
  final dia = soDia(hoje);
  final limite = dia.add(const Duration(days: 7));

  var atrasadas = 0, aVencer = 0, noMes = 0;
  var valorAtrasadas = 0.0, valorAVencer = 0.0, valorNoMes = 0.0;

  for (final c in contas) {
    if (c.paga) continue;
    final venc = soDia(c.vencimento);

    if (venc.isBefore(dia)) {
      atrasadas++;
      valorAtrasadas += c.valor;
    } else if (!venc.isAfter(limite)) {
      aVencer++;
      valorAVencer += c.valor;
    }

    if (venc.year == dia.year && venc.month == dia.month) {
      noMes++;
      valorNoMes += c.valor;
    }
  }

  return ResumoContas(
    atrasadas: atrasadas,
    valorAtrasadas: valorAtrasadas,
    aVencerEm7Dias: aVencer,
    valorAVencerEm7Dias: valorAVencer,
    pendentesNoMes: noMes,
    valorPendenteNoMes: valorNoMes,
  );
}
