import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';

/// Dados de exemplo da tela de Orçamento — ver Budget.dc.html. Substituir
/// por `BudgetRepository` quando a persistência real existir (fase 2,
/// `.claude/plans/MVP.md`).
class BudgetEnvelope {
  const BudgetEnvelope({
    required this.name,
    required this.icon,
    required this.spent,
    required this.limit,
  });

  final String name;
  final String icon;
  final double spent;
  final double limit;

  double get ratio => spent / limit;
}

const _baseEnvelopes = [
  BudgetEnvelope(name: 'Alimentação', icon: 'A', spent: 1140, limit: 2000),
  BudgetEnvelope(name: 'Transporte', icon: 'T', spent: 520, limit: 600),
  BudgetEnvelope(name: 'Lazer', icon: 'L', spent: 940, limit: 1000),
  BudgetEnvelope(name: 'Casa', icon: 'C', spent: 1480, limit: 2400),
];

class BudgetState {
  const BudgetState({this.envelopes = _baseEnvelopes});

  final List<BudgetEnvelope> envelopes;

  double get totalSpent => envelopes.fold(0, (acc, e) => acc + e.spent);
  double get totalLimit => envelopes.fold(0, (acc, e) => acc + e.limit);
}

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(BudgetNotifier.new);

class BudgetNotifier extends Notifier<BudgetState> {
  @override
  BudgetState build() => const BudgetState();

  void addHealthEnvelope() {
    if (state.envelopes.any((e) => e.name == 'Saúde')) return;
    state = BudgetState(
      envelopes: [
        ...state.envelopes,
        const BudgetEnvelope(name: 'Saúde', icon: 'S', spent: 90, limit: 400),
      ],
    );
  }
}

/// Cor do indicador: verde (<70%), âmbar (70–90%), vermelho (≥90%).
Color envelopeColor(AppSurfaceTokens tokens, double ratio) {
  if (ratio >= .9) return tokens.neg;
  if (ratio >= .7) return AppColors.alerta.withValues(alpha: .85);
  return tokens.pos;
}

String envelopeStatus(double ratio, double remaining) {
  final r = remaining.toStringAsFixed(0);
  if (ratio >= .9) return 'Perto do limite · restam R\$ $r';
  if (ratio >= .7) return 'Atenção · restam R\$ $r';
  return 'Dentro do orçamento · restam R\$ $r';
}
