import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/core/widgets/app_help_button.dart';
import 'package:teofinance/features/planejamento/domain/services/projetar_fluxo_de_caixa.dart';
import 'package:teofinance/features/planejamento/presentation/providers/planejamento_providers.dart';

const _semana = ['segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo'];

String _dia(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String _quando(DateTime data) {
  final hoje = DateTime.now();
  final dias = DateTime(data.year, data.month, data.day).difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;
  return switch (dias) {
    <= 0 => 'hoje',
    1 => 'amanhã',
    _ => 'em $dias dias',
  };
}

/// O saldo da conta dia a dia nos próximos 60 dias, com salário, contas e faturas.
class FluxoDeCaixaScreen extends ConsumerWidget {
  const FluxoDeCaixaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final fluxo = ref.watch(fluxoDeCaixaProvider);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Fluxo de caixa', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        actions: const [
          AppHelpButton(
            titulo: 'Como funciona o fluxo de caixa',
            paragrafos: [
              'Parte do seu saldo na conta de hoje e soma, dia a dia, o que entra (salário e outras rendas) e o que sai (contas a pagar e faturas dos cartões).',
              'Contas que se repetem aparecem de novo no mês seguinte. Conta vencida e não paga é tratada como saindo hoje.',
              'Reembolsos a receber não entram, porque não têm data certa.',
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _Resumo(fluxo: fluxo),
            const SizedBox(height: 12),
            if (fluxo.dias.isNotEmpty) ...[
              _Grafico(fluxo: fluxo),
              const SizedBox(height: 12),
            ],
            const _ComoLer(),
            const SizedBox(height: 16),
            Text('Dia a dia', style: TextStyle(color: t.ink, fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 8),
            if (fluxo.dias.isEmpty)
              Text(
                'Nada previsto nos próximos ${fluxo.horizonteDias} dias. '
                'Cadastre receitas fixas, contas a pagar ou compras no cartão para ver o saldo evoluir.',
                style: TextStyle(color: t.sub),
              ),
            for (final d in fluxo.dias) _Dia(dia: d, menor: d == fluxo.menorSaldo),
          ],
        ),
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.fluxo});

  final FluxoDeCaixa fluxo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final falta = fluxo.primeiraFalta;
    final menor = fluxo.menorSaldo;
    final eventos = [for (final d in fluxo.dias) ...d.eventos];
    final entra = eventos.where((e) => e.valor > 0).fold(0.0, (a, e) => a + e.valor);
    final sai = eventos.where((e) => e.valor < 0).fold(0.0, (a, e) => a - e.valor);

    final fundo = falta != null ? t.negBg : t.hero;
    final texto = falta != null ? t.neg : Colors.white;
    final suave = falta != null ? t.neg : Colors.white.withValues(alpha: .8);

    Widget coluna(String rotulo, double valor) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rotulo, style: TextStyle(color: suave, fontSize: 11.5)),
              AppAmountText(
                formatCurrency(valor),
                style: TextStyle(color: texto, fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text('Saldo na conta hoje', style: TextStyle(color: suave, fontSize: 13)),
              AppAmountText(
                formatCurrency(fluxo.saldoInicial),
                style: TextStyle(color: texto, fontSize: 28, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          Row(
            children: [
              coluna('Vai entrar', entra),
              coluna('Vai sair', sai),
              coluna('Em ${fluxo.horizonteDias} dias', fluxo.saldoFinal),
            ],
          ),
          if (falta != null)
            Text(
              'Atenção: em ${_dia(falta.data)} o saldo cai para ${formatCurrency(falta.saldo)}. '
              'Veja se entra dinheiro antes dessa data ou se dá para adiar alguma saída.',
              style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600),
            )
          else if (menor != null)
            Text(
              'Tudo certo: o menor saldo previsto é ${formatCurrency(menor.saldo)}, em ${_dia(menor.data)}.',
              style: TextStyle(color: suave, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

class _Grafico extends StatelessWidget {
  const _Grafico({required this.fluxo});

  final FluxoDeCaixa fluxo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final inicio = DateTime.now();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(color: t.card, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text('Como o saldo evolui', style: TextStyle(color: t.ink, fontWeight: FontWeight.w800, fontSize: 14)),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: _LinhaDoSaldo(
                fluxo: fluxo,
                hoje: DateTime(inicio.year, inicio.month, inicio.day),
                linha: t.hero,
                negativo: t.neg,
                grade: t.line,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('hoje', style: TextStyle(color: t.sub, fontSize: 11)),
              Text('em ${fluxo.horizonteDias} dias', style: TextStyle(color: t.sub, fontSize: 11)),
            ],
          ),
          Text(
            'A linha sobe quando entra dinheiro e desce quando sai. Pontos vermelhos são dias com saldo negativo.',
            style: TextStyle(color: t.sub, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

/// Linha em degraus: o saldo fica igual até o próximo dia com movimento.
class _LinhaDoSaldo extends CustomPainter {
  _LinhaDoSaldo({required this.fluxo, required this.hoje, required this.linha, required this.negativo, required this.grade});

  final FluxoDeCaixa fluxo;
  final DateTime hoje;
  final Color linha;
  final Color negativo;
  final Color grade;

  @override
  void paint(Canvas canvas, Size size) {
    final pontos = <(double, double)>[(0, fluxo.saldoInicial)];
    for (final d in fluxo.dias) {
      final x = d.data.difference(hoje).inDays.clamp(0, fluxo.horizonteDias).toDouble();
      pontos
        ..add((x, pontos.last.$2))
        ..add((x, d.saldo));
    }
    pontos.add((fluxo.horizonteDias.toDouble(), pontos.last.$2));

    var menor = pontos.map((p) => p.$2).reduce((a, b) => a < b ? a : b);
    var maior = pontos.map((p) => p.$2).reduce((a, b) => a > b ? a : b);
    if (menor > 0) menor = 0;
    if (maior < 0) maior = 0;
    if (maior == menor) maior = menor + 1;

    const margem = 6.0;
    final altura = size.height - margem * 2;
    double px(double x) => x / fluxo.horizonteDias * size.width;
    double py(double y) => margem + (maior - y) / (maior - menor) * altura;

    canvas.drawLine(
      Offset(0, py(0)),
      Offset(size.width, py(0)),
      Paint()
        ..color = grade
        ..strokeWidth = 1,
    );

    final caminho = Path()..moveTo(px(pontos.first.$1), py(pontos.first.$2));
    for (final p in pontos.skip(1)) {
      caminho.lineTo(px(p.$1), py(p.$2));
    }
    canvas.drawPath(
      caminho,
      Paint()
        ..color = linha
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );

    for (final d in fluxo.dias.where((d) => d.saldo < 0)) {
      final x = d.data.difference(hoje).inDays.clamp(0, fluxo.horizonteDias).toDouble();
      canvas.drawCircle(Offset(px(x), py(d.saldo)), 3.5, Paint()..color = negativo);
    }
  }

  @override
  bool shouldRepaint(_LinhaDoSaldo old) => old.fluxo != fluxo || old.linha != linha;
}

class _ComoLer extends StatelessWidget {
  const _ComoLer();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    Widget item(IconData icone, Color cor, String titulo, String texto) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Icon(icone, size: 18, color: cor),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '$titulo ', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
                    TextSpan(text: texto),
                  ],
                ),
                style: TextStyle(color: t.sub, fontSize: 12.5),
              ),
            ),
          ],
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.card, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text('O que entra nesta previsão', style: TextStyle(color: t.ink, fontWeight: FontWeight.w800, fontSize: 14)),
          item(Icons.south_west, t.pos, 'Entradas:', 'salário e outras receitas fixas, na data em que costumam cair.'),
          item(Icons.receipt_long_outlined, t.ink, 'Contas:', 'contas a pagar em aberto; as que se repetem aparecem de novo.'),
          item(Icons.credit_card, t.ink, 'Faturas:', 'o valor total que o banco cobra, no dia do vencimento.'),
          Text(
            'Fica de fora: reembolsos a receber (sem data certa) e gastos do dia a dia que ainda não aconteceram.',
            style: TextStyle(color: t.sub, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

IconData _icone(TipoEventoFluxo tipo) => switch (tipo) {
      TipoEventoFluxo.entrada => Icons.south_west,
      TipoEventoFluxo.conta => Icons.receipt_long_outlined,
      TipoEventoFluxo.fatura => Icons.credit_card,
    };

class _Dia extends StatelessWidget {
  const _Dia({required this.dia, required this.menor});

  final DiaDoFluxo dia;
  final bool menor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final negativo = dia.saldo < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: negativo ? t.neg : t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_dia(dia.data)} · ${_semana[dia.data.weekday - 1]} · ${_quando(dia.data)}',
                  style: TextStyle(color: t.ink, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              if (menor)
                Text('menor saldo', style: TextStyle(color: t.sub, fontSize: 11, fontStyle: FontStyle.italic)),
            ],
          ),
          for (final e in dia.eventos)
            Row(
              spacing: 10,
              children: [
                Icon(_icone(e.tipo), size: 16, color: e.valor >= 0 ? t.pos : t.sub),
                Expanded(child: Text(e.descricao, style: TextStyle(color: t.ink, fontSize: 13.5))),
                AppAmountText(
                  e.valor >= 0 ? '+ ${formatCurrency(e.valor)}' : '- ${formatCurrency(-e.valor)}',
                  style: TextStyle(color: e.valor >= 0 ? t.pos : t.ink, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ],
            ),
          Divider(height: 1, color: t.line),
          Row(
            children: [
              Expanded(child: Text('Saldo ao fim do dia', style: TextStyle(color: t.sub, fontSize: 12))),
              AppAmountText(
                formatCurrency(dia.saldo),
                style: TextStyle(color: negativo ? t.neg : t.ink, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
