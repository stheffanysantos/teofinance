import 'package:flutter/material.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/extrato_linha.dart';
import '../../domain/entities/reconciliation_match.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';

class MatchCard extends StatelessWidget {
  final ReconciliationMatch match;
  final Transacao? transacao;
  final ExtratoLinha? linha;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const MatchCard({
    required this.match,
    this.transacao,
    this.linha,
    this.onApprove,
    this.onReject,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final confidenceColor = _corConfianca(match.confidence, t);
    final statusColor = _corStatus(match.status, t);

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 8,
            children: [
              _Chip(label: _rotulo(match.status), color: statusColor),
              if (match.confidence > 0)
                _Chip(
                  label: '${(match.confidence * 100).toStringAsFixed(0)}%',
                  color: confidenceColor,
                ),
            ],
          ),
          if (transacao != null)
            _Linha(
              titulo: 'Seu lançamento',
              descricao: transacao!.descricao,
              valor: transacao!.valorCobrado,
              data: transacao!.data,
            ),
          if (linha != null)
            _Linha(
              titulo: 'Extrato do banco',
              descricao: linha!.descricao,
              valor: linha!.valorAsTransacao,
              data: linha!.data,
            ),
          if (onApprove != null || onReject != null)
            Row(
              spacing: 8,
              children: [
                if (onApprove != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Aprovar'),
                      style: FilledButton.styleFrom(backgroundColor: t.pos),
                    ),
                  ),
                if (onReject != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Rejeitar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: t.neg,
                        side: BorderSide(color: t.neg),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _rotulo(String status) => switch (status) {
        'auto_matched' => 'Combinado',
        'manual_matched' => 'Aprovado',
        'unmatched' => 'Revisar',
        'orphan' => 'Sem lançamento',
        _ => status,
      };

  Color _corStatus(String status, AppSurfaceTokens t) => switch (status) {
        'auto_matched' || 'manual_matched' => t.pos,
        'unmatched' => AppColors.aviso,
        'orphan' => t.neg,
        _ => t.sub,
      };

  Color _corConfianca(double confidence, AppSurfaceTokens t) {
    if (confidence >= 0.95) return t.pos;
    if (confidence >= 0.75) return AppColors.aviso;
    return t.neg;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.titulo,
    required this.descricao,
    required this.valor,
    required this.data,
  });

  final String titulo;
  final String descricao;
  final double valor;
  final DateTime data;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final dataTexto = '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.bg,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(titulo, style: TextStyle(fontSize: 11, color: t.sub)),
                Text(
                  descricao,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.ink),
                ),
                Text(dataTexto, style: TextStyle(fontSize: 11, color: t.sub)),
              ],
            ),
          ),
          AppAmountText(
            valor.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valor < 0 ? t.neg : t.pos,
            ),
          ),
        ],
      ),
    );
  }
}
