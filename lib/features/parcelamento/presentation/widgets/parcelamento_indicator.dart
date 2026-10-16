import 'package:flutter/material.dart';

import '../../domain/entities/parcelamento.dart';
import '../../../transacao/domain/entities/transacao.dart';

/// Widget que exibe um badge com informações de parcelamento ("Parcela 3/12").
/// Mostra apenas se a transação é uma parcela.
class ParcelamentoIndicator extends StatelessWidget {
  final Transacao transacao;
  final Parcelamento? parcelamento;

  const ParcelamentoIndicator({
    super.key,
    required this.transacao,
    this.parcelamento,
  });

  @override
  Widget build(BuildContext context) {
    if (!transacao.ehParcela || transacao.numeroParcela == null) {
      return const SizedBox.shrink();
    }

    final totalParcelas = parcelamento?.numeroParcelas ??
        1; // Fallback se parcelamento não foi carregado

    return Chip(
      label: Text(
        'Parcela ${transacao.numeroParcela}/$totalParcelas',
        style: Theme.of(context).textTheme.labelSmall,
      ),
      avatar: const Icon(Icons.calendar_month, size: 16),
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      side: BorderSide(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
      ),
    );
  }
}
