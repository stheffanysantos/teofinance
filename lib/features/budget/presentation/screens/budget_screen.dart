import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/presentation/providers/budget_providers.dart';
import 'package:teofinance/features/budget/presentation/widgets/definir_limite_sheet.dart';

const _meses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

/// Tela de Orçamento (envelopes por categoria). Acessada a partir do cartão
/// "Despesas" do Dashboard.
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  Future<void> _abrirSheet(
    BuildContext context, {
    required List<String> categoriasLivres,
    Orcamento? existente,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DefinirLimiteSheet(categoriasLivres: categoriasLivres, existente: existente),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final resumo = ref.watch(resumoOrcamentoProvider);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: resumo.when(
          loading: () => Center(child: CircularProgressIndicator(color: t.pos)),
          error: (_, _) => Center(
            child: Text('Não foi possível carregar o orçamento.', style: TextStyle(color: t.sub)),
          ),
          data: (r) {
            final usadas = r.envelopes.map((e) => e.categoria).toSet();
            final livres = DefinirLimiteSheet.categoriasOrcaveis().where((c) => !usadas.contains(c)).toList();
            return _Conteudo(
              resumo: r,
              onNovo: () => _abrirSheet(context, categoriasLivres: livres),
              onEditar: (o) => _abrirSheet(context, categoriasLivres: const [], existente: o),
            );
          },
        ),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.resumo, required this.onNovo, required this.onEditar});

  final ResumoOrcamento resumo;
  final VoidCallback onNovo;
  final ValueChanged<Orcamento> onEditar;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hoje = DateTime.now();
    final diasRestantes = DateTime(hoje.year, hoje.month + 1, 0).day - hoje.day;
    final temEnvelopes = resumo.envelopes.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 18,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Envelopes · ${_meses[hoje.month - 1]}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: t.sub),
                  ),
                  Text(
                    'Orçamento',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.5, color: t.ink),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onNovo,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Icon(Icons.add, size: 24, color: t.accentInk),
                ),
              ),
            ],
          ),
          if (!temEnvelopes)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: t.card,
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                spacing: 8,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 40, color: t.sub),
                  Text(
                    'Nenhum limite definido',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.ink),
                  ),
                  Text(
                    'Defina quanto quer gastar por mês em cada categoria e acompanhe aqui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: t.sub),
                  ),
                  FilledButton(onPressed: onNovo, child: const Text('Definir primeiro limite')),
                ],
              ),
            )
          else ...[
            _Resumo(resumo: resumo, diasRestantes: diasRestantes),
            Column(
              spacing: 12,
              children: [
                for (final e in resumo.envelopes)
                  _EnvelopeCard(envelope: e, onTap: () => onEditar(e.orcamento)),
              ],
            ),
            GestureDetector(
              onTap: onNovo,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: t.sub, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Text('+', style: TextStyle(fontSize: 20, color: t.sub)),
                    Text('Nova categoria', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: t.sub)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.resumo, required this.diasRestantes});

  final ResumoOrcamento resumo;
  final int diasRestantes;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textoClaro = Colors.white.withValues(alpha: .8);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total gasto', style: TextStyle(color: textoClaro, fontSize: 13)),
              AppAmountText(
                'R\$ ${resumo.totalLimite.toStringAsFixed(0)}',
                prefix: 'Limite ',
                style: TextStyle(color: textoClaro, fontSize: 13),
              ),
            ],
          ),
          AppAmountText(
            'R\$ ${resumo.totalGasto.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: resumo.proporcao.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: .18),
              valueColor: AlwaysStoppedAnimation(t.accent),
            ),
          ),
          AppAmountText(
            'R\$ ${resumo.totalRestante.abs().toStringAsFixed(0)}',
            prefix: resumo.totalRestante < 0 ? 'Acima do limite em ' : 'Restam ',
            suffix: ' · $diasRestantes dias até o fim do mês',
            style: TextStyle(color: textoClaro, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EnvelopeCard extends StatelessWidget {
  const _EnvelopeCard({required this.envelope, required this.onTap});

  final EnvelopeOrcamento envelope;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cor = envelopeColor(t, envelope.proporcao);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.card,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              spacing: 12,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(
                    envelope.categoria.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: cor, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        envelope.categoria,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.ink),
                      ),
                      Text(
                        envelopeStatus(envelope.proporcao, envelope.restante),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cor),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppAmountText(
                      'R\$ ${envelope.gasto.toStringAsFixed(0)}',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: t.ink),
                    ),
                    AppAmountText(
                      'R\$ ${envelope.limite.toStringAsFixed(0)}',
                      prefix: 'de ',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.sub),
                    ),
                  ],
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: envelope.proporcao.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: t.track,
                valueColor: AlwaysStoppedAnimation(cor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
