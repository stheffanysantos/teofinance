import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/utils/date_label.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/core/widgets/app_help_button.dart';
import 'package:teofinance/features/planejamento/domain/services/cobertura_da_reserva.dart';
import 'package:teofinance/features/planejamento/domain/services/ritmo_do_mes.dart';
import 'package:teofinance/features/planejamento/presentation/providers/planejamento_providers.dart';
import 'package:teofinance/features/planejamento/presentation/screens/a_pagar_no_proximo_mes_screen.dart';
import 'package:teofinance/features/planejamento/presentation/screens/fluxo_de_caixa_screen.dart';
import 'package:teofinance/features/planejamento/presentation/screens/plano_do_mes_screen.dart';
import 'package:teofinance/features/planejamento/presentation/screens/simulador_parcelamento_screen.dart';
import 'package:teofinance/features/recorrentes/presentation/screens/gastos_recorrentes_screen.dart';

String _dia(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

void _abrir(BuildContext context, Widget tela) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => tela));

/// Central de planejamento: o plano do mês, o ritmo dos gastos, o fluxo de caixa,
/// a reserva de emergência e o simulador de compra parcelada.
class PlanejamentoScreen extends ConsumerWidget {
  const PlanejamentoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Planejamento', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        actions: const [
          AppHelpButton(
            titulo: 'Como funciona o planejamento',
            paragrafos: [
              'Reúne cinco visões para decidir antes de gastar: o plano do mês (quanto gastar por categoria e ainda guardar), o ritmo dos seus gastos no orçamento, o fluxo de caixa dos próximos 60 dias, a cobertura da sua reserva de emergência e um simulador de compra parcelada.',
              'Tudo é calculado no seu aparelho, com os dados que você já cadastrou. São sugestões de organização, não recomendação de investimento.',
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: const SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            spacing: 12,
            children: [
              _APagarCard(),
              _PlanoCard(),
              _RitmoCard(),
              _FluxoCard(),
              _ReservaCard(),
              _AtalhosCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bloco extends StatelessWidget {
  const _Bloco({required this.titulo, required this.icone, required this.child, this.onTap});

  final String titulo;
  final IconData icone;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(side: BorderSide(color: t.line), borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                spacing: 8,
                children: [
                  Icon(icone, size: 18, color: t.ink),
                  Expanded(child: Text(titulo, style: TextStyle(color: t.ink, fontWeight: FontWeight.w800, fontSize: 15))),
                  if (onTap != null) Icon(Icons.chevron_right, color: t.sub),
                ],
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _APagarCard extends ConsumerWidget {
  const _APagarCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final r = ref.watch(aPagarNoProximoMesProvider);
    final nome = kMesesPorExtenso[r.mes - 1];

    return _Bloco(
      titulo: 'A pagar em $nome',
      icone: Icons.event_note_outlined,
      onTap: () => _abrir(context, const APagarNoProximoMesScreen()),
      child: r.itens.isEmpty
          ? Text('Nada a pagar em $nome por enquanto.', style: TextStyle(color: t.sub, fontSize: 13))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                AppAmountText(
                  formatCurrency(r.total),
                  style: TextStyle(color: t.ink, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                AppAmountText(
                  formatCurrency(r.cartoes),
                  prefix: 'Cartões ',
                  suffix: ' · Contas ${formatCurrency(r.contas)}',
                  style: TextStyle(color: t.sub, fontSize: 12.5),
                ),
              ],
            ),
    );
  }
}

class _PlanoCard extends ConsumerWidget {
  const _PlanoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final plano = ref.watch(planoDoMesProvider);

    return _Bloco(
      titulo: 'Plano do mês',
      icone: Icons.savings_outlined,
      onTap: () => _abrir(context, const PlanoDoMesScreen()),
      child: plano == null
          ? Text(
              'Cadastre seu salário em Receitas (renda fixa) e o app sugere quanto gastar em cada categoria e ainda guardar.',
              style: TextStyle(color: t.sub, fontSize: 13),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                AppAmountText(
                  formatCurrency(plano.metaGuardar),
                  prefix: 'Guardar ',
                  suffix: ' e gastar até ${formatCurrency(plano.disponivel)}',
                  style: TextStyle(color: t.ink, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  plano.viavel
                      ? (plano.folga >= 1
                          ? 'Cabe nos seus gastos de hoje, com folga de ${formatCurrency(plano.folga)}.'
                          : 'Cabe, ajustando algumas categorias.')
                      : 'Não cabe: faltam ${formatCurrency(plano.faltaCobrir)} mesmo cortando o que dá.',
                  style: TextStyle(color: plano.viavel ? t.sub : t.neg, fontSize: 12.5),
                ),
              ],
            ),
    );
  }
}

class _RitmoCard extends ConsumerWidget {
  const _RitmoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final ritmo = ref.watch(ritmoDoMesProvider);
    final atencao = ritmo.where((r) => r.situacao != SituacaoRitmo.ok).take(3).toList();

    return _Bloco(
      titulo: 'Ritmo do mês',
      icone: Icons.speed_outlined,
      child: ritmo.isEmpty
          ? Text('Defina limites no Orçamento para eu acompanhar o ritmo de cada categoria.',
              style: TextStyle(color: t.sub, fontSize: 13))
          : atencao.isEmpty
              ? Text('Todas as categorias estão no ritmo do mês.', style: TextStyle(color: t.pos, fontSize: 13))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    for (final r in atencao)
                      Text(
                        r.situacao == SituacaoRitmo.estourado
                            ? '${r.categoria}: passou do limite (${formatCurrency(r.gasto)} de ${formatCurrency(r.limite)}).'
                            : '${r.categoria}: já usou ${(r.consumido * 100).round()}% do limite; '
                                'neste ritmo chega a ${formatCurrency(r.previsto)} no fim do mês.',
                        style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
    );
  }
}

class _FluxoCard extends ConsumerWidget {
  const _FluxoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final fluxo = ref.watch(fluxoDeCaixaProvider);
    final falta = fluxo.primeiraFalta;
    final menor = fluxo.menorSaldo;

    return _Bloco(
      titulo: 'Fluxo de caixa',
      icone: Icons.timeline_outlined,
      onTap: () => _abrir(context, const FluxoDeCaixaScreen()),
      child: falta != null
          ? Text(
              'O saldo pode ficar negativo em ${_dia(falta.data)} (${formatCurrency(falta.saldo)}).',
              style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600),
            )
          : Text(
              menor == null
                  ? 'Nada previsto nos próximos ${fluxo.horizonteDias} dias.'
                  : 'Nos próximos ${fluxo.horizonteDias} dias o menor saldo previsto é '
                      '${formatCurrency(menor.saldo)}, em ${_dia(menor.data)}.',
              style: TextStyle(color: t.sub, fontSize: 13),
            ),
    );
  }
}

class _ReservaCard extends ConsumerWidget {
  const _ReservaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final c = ref.watch(coberturaDaReservaProvider);
    final meses = c.meses;

    final texto = meses == null
        ? 'Ainda não há histórico de gastos para calcular quantos meses a reserva cobre.'
        : 'Sua reserva (${formatCurrency(c.reserva)} em investimentos de resgate rápido) cobre '
            '${meses.toStringAsFixed(1).replaceAll('.', ',')} meses de gastos. '
            '${c.falta > 0 ? 'Faltam ${formatCurrency(c.falta)} para ${c.alvoMeses} meses.' : 'Você já passou da referência de ${c.alvoMeses} meses.'}';

    return _Bloco(
      titulo: 'Reserva de emergência',
      icone: Icons.shield_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          if (meses != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: c.progresso,
                minHeight: 8,
                backgroundColor: t.track,
                color: switch (c.nivel) {
                  NivelDaReserva.baixa => t.neg,
                  NivelDaReserva.razoavel => t.accent,
                  _ => t.pos,
                },
              ),
            ),
          Text(texto, style: TextStyle(color: t.sub, fontSize: 13)),
        ],
      ),
    );
  }
}

class _AtalhosCard extends StatelessWidget {
  const _AtalhosCard();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(side: BorderSide(color: t.line), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.calculate_outlined, color: t.ink),
            title: Text('Simular compra parcelada', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
            subtitle: Text('Veja o efeito nas próximas faturas antes de comprar.', style: TextStyle(color: t.sub, fontSize: 12)),
            trailing: Icon(Icons.chevron_right, color: t.sub),
            onTap: () => _abrir(context, const SimuladorParcelamentoScreen()),
          ),
          Divider(height: 1, color: t.line),
          ListTile(
            leading: Icon(Icons.repeat, color: t.ink),
            title: Text('Gastos recorrentes', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
            subtitle: Text('Assinaturas e cobranças que se repetem.', style: TextStyle(color: t.sub, fontSize: 12)),
            trailing: Icon(Icons.chevron_right, color: t.sub),
            onTap: () => _abrir(context, const GastosRecorrentesScreen()),
          ),
        ],
      ),
    );
  }
}
