import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

import '../../domain/entities/extrato_linha.dart';
import '../notifiers/reconciliation_notifier.dart';
import '../providers/reconciliation_providers.dart';
import '../widgets/match_card.dart';
import '../widgets/orphan_card.dart';
import '../widgets/reconciliation_report_card.dart';
import '../widgets/reconciliation_summary.dart';
import '../widgets/sem_extrato_card.dart';

const _meses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

class ReconciliationScreen extends ConsumerStatefulWidget {
  const ReconciliationScreen({super.key});

  @override
  ConsumerState<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends ConsumerState<ReconciliationScreen> {
  late DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _executar());
  }

  Future<void> _executar() {
    final inicio = DateTime(_mes.year, _mes.month);
    final fim = DateTime(_mes.year, _mes.month + 1).subtract(const Duration(milliseconds: 1));
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid ?? '';
    return ref.read(reconciliationNotifierProvider.notifier).fazerReconciliacao(
          userId: uid,
          dataInicio: inicio,
          dataFim: fim,
        );
  }

  void _mudarMes(int delta) {
    setState(() => _mes = DateTime(_mes.year, _mes.month + delta));
    _executar();
  }

  Future<void> _aprovar(String id) async {
    await ref.read(reconciliationNotifierProvider.notifier).aprovarMatch(id);
  }

  Future<void> _vincular(ExtratoLinha linha) async {
    final notifier = ref.read(reconciliationNotifierProvider.notifier);
    final candidatas = notifier.candidatasPara(linha);

    final escolhida = await showModalBottomSheet<Transacao>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EscolherTransacao(linha: linha, candidatas: candidatas),
    );
    if (escolhida == null) return;

    await notifier.vincularManualmente(
      transacaoId: escolhida.id,
      linhaExtratoId: linha.id,
    );
  }

  Future<void> _rejeitar(String id) async {
    await ref.read(reconciliationNotifierProvider.notifier).rejeitarMatch(id);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final state = ref.watch(reconciliationNotifierProvider);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        title: Text('Reconciliação', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        iconTheme: IconThemeData(color: t.ink),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _SeletorMes(
              rotulo: '${_meses[_mes.month - 1]} ${_mes.year}',
              onAnterior: () => _mudarMes(-1),
              onProximo: () => _mudarMes(1),
            ),
            Expanded(child: _corpo(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _corpo(BuildContext context, ReconciliationState state) {
    final t = context.tokens;

    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: t.pos));
    }

    if (state.erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Icon(Icons.error_outline, size: 48, color: t.neg),
              Text(state.erro!, textAlign: TextAlign.center, style: TextStyle(color: t.sub)),
              FilledButton(onPressed: _executar, child: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }

    if (state.matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(Icons.fact_check_outlined, size: 48, color: t.sub),
              Text(
                'Nada para reconciliar neste mês',
                style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                'Importe o extrato do banco usando "Reconciliar com minhas transações".',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.sub, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    Widget secao(String status, String titulo, {bool aprovar = false, bool rejeitar = false}) {
      final lista = state.matches.where((m) => m.status == status).toList();
      if (lista.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '$titulo (${lista.length})',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.ink),
            ),
          ),
          for (final m in lista)
            if (status == 'orphan')
              OrphanCard(
                match: m,
                linha: state.linhas[m.linhaExtratoId],
                onVincular: state.linhas[m.linhaExtratoId] == null
                    ? null
                    : () => _vincular(state.linhas[m.linhaExtratoId]!),
              )
            else
              MatchCard(
                match: m,
                transacao: state.transacoes[m.transacaoId],
                linha: state.linhas[m.linhaExtratoId],
                onApprove: aprovar ? () => _aprovar(m.id) : null,
                onReject: rejeitar ? () => _rejeitar(m.id) : null,
              ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        ReconciliationSummary(state: state),
        const SizedBox(height: 12),
        ReconciliationReportCard(state: state),
        secao('unmatched', 'Para revisar', aprovar: true, rejeitar: true),
        secao('orphan', 'No extrato, sem lançamento'),
        secao('auto_matched', 'Combinados automaticamente', rejeitar: true),
        secao('manual_matched', 'Aprovados', rejeitar: true),
        if (state.transacoesSemExtrato.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Registradas, mas fora do extrato (${state.transacoesSemExtrato.length})',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.ink),
                ),
              ),
              for (final tr in state.transacoesSemExtrato) SemExtratoCard(transacao: tr),
            ],
          ),
      ],
    );
  }
}

class _SeletorMes extends StatelessWidget {
  const _SeletorMes({required this.rotulo, required this.onAnterior, required this.onProximo});

  final String rotulo;
  final VoidCallback onAnterior;
  final VoidCallback onProximo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: onAnterior, icon: Icon(Icons.chevron_left, color: t.ink)),
        Text(rotulo, style: TextStyle(fontWeight: FontWeight.w700, color: t.ink)),
        IconButton(onPressed: onProximo, icon: Icon(Icons.chevron_right, color: t.ink)),
      ],
    );
  }
}

class _EscolherTransacao extends StatelessWidget {
  const _EscolherTransacao({required this.linha, required this.candidatas});

  final ExtratoLinha linha;
  final List<Transacao> candidatas;

  String _data(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                'Qual transação é esta linha?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.ink),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                '${linha.descricao} · ${_data(linha.data)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: t.sub, fontSize: 13),
              ),
            ),
            if (candidatas.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Nenhuma transação livre neste mês. Cadastre a transação e volte aqui.',
                  style: TextStyle(color: t.sub),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: candidatas.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: t.line),
                  itemBuilder: (context, i) {
                    final c = candidatas[i];
                    return ListTile(
                      title: Text(c.descricao, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(_data(c.data)),
                      trailing: AppAmountText(
                        c.valorCobrado.toStringAsFixed(2),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.valorCobrado < 0 ? t.neg : t.pos,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(c),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
