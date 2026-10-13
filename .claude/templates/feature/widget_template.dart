import 'package:flutter/material.dart';
import 'package:teofinance/app/theme/app_spacing.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/features/nome_feature/domain/entities/nome_entidade.dart';

/// Widget específico de feature — reaproveita componentes de core/widgets/ sempre que existir um.
class NomeEntidadeCard extends StatelessWidget {
  const NomeEntidadeCard({super.key, required this.entidade});

  final NomeEntidade entidade;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(entidade.descricao),
            AppAmountText(valor: entidade.valor),
          ],
        ),
      ),
    );
  }
}
