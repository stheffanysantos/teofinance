import 'package:flutter/material.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/score/domain/entities/score_financeiro.dart';

/// Explica a nota: cada componente, seu peso e o que ele mediu. Quem vê o
/// número precisa conseguir descobrir o que fazer para melhorá-lo.
class ComoCalculamosScoreSheet extends StatelessWidget {
  const ComoCalculamosScoreSheet({required this.score, super.key});

  final ScoreFinanceiro? score;

  static Future<void> mostrar(BuildContext context, ScoreFinanceiro? score) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ComoCalculamosScoreSheet(score: score),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final componentes = score?.componentes ?? const <ComponenteScore>[];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Text(
              'Como o score é calculado',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.ink),
            ),
            Text(
              'Vai de 0 a 1000 e usa só os dados do mês atual, calculados no seu aparelho. '
              'O que ainda não tem dado fica fora da conta, sem pesar contra você.',
              style: TextStyle(fontSize: 13, color: t.sub, height: 1.4),
            ),
            if (componentes.isEmpty)
              Text('Não foi possível calcular agora.', style: TextStyle(color: t.sub))
            else
              for (final c in componentes) _Componente(componente: c),
          ],
        ),
      ),
    );
  }
}

class _Componente extends StatelessWidget {
  const _Componente({required this.componente});

  final ComponenteScore componente;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fracao = componente.fracao;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                componente.nome,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: t.ink),
              ),
            ),
            Text(
              fracao == null ? 'sem dados' : '${(fracao * 100).round()}%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fracao == null ? t.sub : t.ink),
            ),
            const SizedBox(width: 8),
            Text('peso ${componente.peso}%', style: TextStyle(fontSize: 12, color: t.sub)),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: fracao ?? 0,
            minHeight: 6,
            color: t.pos,
            backgroundColor: t.line,
          ),
        ),
        Text(componente.detalhe, style: TextStyle(fontSize: 12.5, color: t.sub)),
      ],
    );
  }
}
