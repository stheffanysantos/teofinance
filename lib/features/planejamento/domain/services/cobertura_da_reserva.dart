import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/planejamento/domain/services/historico_de_gastos.dart';

/// Tipos de investimento que dá para resgatar rápido: contam como reserva.
const kTiposLiquidos = {
  TipoInvestimento.poupanca,
  TipoInvestimento.rendaFixa,
  TipoInvestimento.tesouroDireto,
  TipoInvestimento.cdb,
};

/// Meses de gasto que uma reserva de emergência deve cobrir (referência comum).
const kAlvoDeMesesDaReserva = 6;

enum NivelDaReserva { baixa, razoavel, solida }

class CoberturaDaReserva {
  const CoberturaDaReserva({
    required this.reserva,
    required this.gastoMensal,
    required this.alvoMeses,
  });

  /// Soma dos investimentos de resgate rápido.
  final double reserva;

  /// Gasto médio por mês, pelo histórico.
  final double gastoMensal;
  final int alvoMeses;

  /// Por quantos meses a reserva paga o padrão de gasto atual; nulo se ainda não
  /// há histórico de gastos para comparar.
  double? get meses => gastoMensal > 0 ? reserva / gastoMensal : null;

  /// Quanto falta para chegar ao alvo.
  double get falta {
    final alvo = gastoMensal * alvoMeses;
    return alvo > reserva ? alvo - reserva : 0;
  }

  double get progresso => gastoMensal <= 0 ? 0 : (reserva / (gastoMensal * alvoMeses)).clamp(0.0, 1.0);

  NivelDaReserva? get nivel {
    final m = meses;
    if (m == null) return null;
    if (m < 3) return NivelDaReserva.baixa;
    if (m < alvoMeses) return NivelDaReserva.razoavel;
    return NivelDaReserva.solida;
  }
}

/// Quantos meses de gasto a reserva (investimentos de resgate rápido) cobre.
CoberturaDaReserva calcularCoberturaDaReserva({
  required List<Investimento> investimentos,
  required HistoricoDeGastos historico,
  int alvoMeses = kAlvoDeMesesDaReserva,
}) {
  final reserva = investimentos.where((i) => kTiposLiquidos.contains(i.tipo)).fold(0.0, (a, i) => a + i.valorAtual);
  return CoberturaDaReserva(reserva: reserva, gastoMensal: historico.mediaTotal, alvoMeses: alvoMeses);
}
