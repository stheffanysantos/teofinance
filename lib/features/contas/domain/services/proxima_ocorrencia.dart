import 'dart:math' as math;

import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';

/// Vencimento seguinte de uma conta recorrente, ou nulo se ela não se repete.
///
/// Parte do [diaBase] e não do último vencimento: uma conta do dia 31 vai para
/// 28/fev e volta para 31/mar, em vez de ficar presa no 28. O mês de destino é
/// calculado antes do dia, porque `DateTime(2026, 2, 31)` vira 3 de março em
/// silêncio.
DateTime? proximoVencimento({
  required DateTime vencimento,
  required int diaBase,
  required RecorrenciaConta recorrencia,
}) {
  final meses = switch (recorrencia) {
    RecorrenciaConta.nenhuma => null,
    RecorrenciaConta.mensal => 1,
    RecorrenciaConta.anual => 12,
  };
  if (meses == null) return null;

  final primeiroDoMes = DateTime(vencimento.year, vencimento.month + meses);
  final ultimoDia = DateTime(primeiroDoMes.year, primeiroDoMes.month + 1, 0).day;
  return DateTime(primeiroDoMes.year, primeiroDoMes.month, math.min(diaBase, ultimoDia));
}
