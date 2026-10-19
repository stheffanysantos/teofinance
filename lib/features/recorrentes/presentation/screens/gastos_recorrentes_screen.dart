import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/widgets/app_amount_text.dart';
import 'package:teofinance/features/recorrentes/domain/entities/gasto_recorrente.dart';
import 'package:teofinance/features/recorrentes/presentation/providers/recorrentes_providers.dart';

String _data(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Assinaturas, mensalidades e contas que se repetem, descobertas no histórico.
class GastosRecorrentesScreen extends ConsumerWidget {
  const GastosRecorrentesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final gastos = ref.watch(gastosRecorrentesProvider);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Gastos recorrentes', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: gastos.when(
          loading: () => Center(child: CircularProgressIndicator(color: t.pos)),
          error: (_, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Não foi possível analisar seus gastos agora.',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.sub),
              ),
            ),
          ),
          data: (lista) => lista.isEmpty ? const _Vazio() : _Conteudo(gastos: lista),
        ),
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Icon(Icons.repeat, size: 44, color: t.sub),
            Text(
              'Nenhum gasto recorrente encontrado',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.ink),
            ),
            Text(
              'Preciso de pelo menos 3 cobranças seguidas (por exemplo, 3 meses de uma assinatura) '
              'para reconhecer um padrão. Importe mais extratos e volte aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: t.sub, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.gastos});

  final List<GastoRecorrente> gastos;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ativos = gastos.where((g) => g.ativa).toList();
    final inativos = gastos.where((g) => !g.ativa).toList();
    final totalMensal = ativos.fold<double>(0, (soma, g) => soma + g.valorMensalEstimado);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(
                'Peso fixo por mês',
                style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13),
              ),
              AppAmountText(
                formatCurrency(totalMensal),
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
              ),
              Text(
                '${ativos.length} ${ativos.length == 1 ? 'gasto ativo' : 'gastos ativos'}'
                ' · estimativa com base no histórico',
                style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final g in ativos) ...[_Cartao(gasto: g), const SizedBox(height: 10)],
        if (inativos.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Provavelmente cancelados (${inativos.length})',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Pararam de aparecer no extrato. Confira se foram cancelados mesmo.',
            style: TextStyle(fontSize: 12.5, color: t.sub),
          ),
          const SizedBox(height: 10),
          for (final g in inativos) ...[_Cartao(gasto: g), const SizedBox(height: 10)],
        ],
      ],
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({required this.gasto});

  final GastoRecorrente gasto;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final apagado = !gasto.ativa;

    return Opacity(
      opacity: apagado ? .65 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.card,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    gasto.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.ink),
                  ),
                ),
                const SizedBox(width: 12),
                AppAmountText(
                  formatCurrency(gasto.ultimoValor),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: t.neg),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Selo(gasto.cadencia.rotulo, t.sub),
                _Selo(gasto.regularidade.rotulo, t.sub),
                if (gasto.variacaoDoUltimo != null) _SeloReajuste(variacao: gasto.variacaoDoUltimo!),
              ],
            ),
            Text(
              apagado
                  ? 'Última cobrança em ${_data(gasto.ultimaData)} · ${gasto.ocorrencias} registros'
                  : 'Última em ${_data(gasto.ultimaData)} · próxima por volta de ${_data(gasto.proximaData)}',
              style: TextStyle(fontSize: 12, color: t.sub),
            ),
          ],
        ),
      ),
    );
  }
}

class _Selo extends StatelessWidget {
  const _Selo(this.texto, this.cor);

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: cor.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)),
      child: Text(texto, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cor)),
    );
  }
}

class _SeloReajuste extends StatelessWidget {
  const _SeloReajuste({required this.variacao});

  final double variacao;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final subiu = variacao > 0;
    final pct = (variacao.abs() * 100).round();
    // Cores de despesa/receita (não `aviso`, reservado a orçamento e sync): subir é
    // gastar mais, cair é gastar menos.
    return _Selo(subiu ? 'Subiu $pct%' : 'Caiu $pct%', subiu ? t.neg : t.pos);
  }
}
