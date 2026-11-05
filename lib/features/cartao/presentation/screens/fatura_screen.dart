import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/utils/date_label.dart';
import 'package:teofinance/core/widgets/app_confirm_dialog.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/periodo_fatura.dart';
import 'package:teofinance/features/cartao/domain/services/resumo_faturas.dart';
import 'package:teofinance/features/cartao/presentation/providers/cartao_providers.dart';
import 'package:teofinance/features/cartao/presentation/screens/vincular_compras_screen.dart';
import 'package:teofinance/features/reconciliation/presentation/screens/reconciliation_screen.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';
import 'package:teofinance/features/transacao/presentation/screens/nova_transacao_screen.dart';

String _data(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// Fatura de um cartão: período, vencimento, total, compras e situação.
class FaturaScreen extends ConsumerStatefulWidget {
  const FaturaScreen({required this.cartaoId, super.key});

  final String cartaoId;

  @override
  ConsumerState<FaturaScreen> createState() => _FaturaScreenState();
}

class _FaturaScreenState extends ConsumerState<FaturaScreen> {
  ({int ano, int mes})? _ref;

  /// Tira o cartão das compras: elas voltam a "sem cartão" e podem ser
  /// corrigidas e vinculadas de novo.
  Future<void> _desvincular(List<Transacao> compras) async {
    final repo = ref.read(transacaoRepositoryProvider);
    for (final x in compras) {
      await repo.definirCartao(id: x.id, cartaoId: null);
    }
  }

  Future<void> _desvincularTodas(List<Transacao> compras) async {
    final confirmou = await AppConfirmDialog.mostrar(
      context,
      titulo: 'Desvincular ${compras.length} compras?',
      mensagem: 'Elas saem desta fatura e ficam sem cartão, sem perder nada. '
          'Depois você corrige e vincula de novo em "Vincular compras sem cartão".',
      rotuloConfirmar: 'Desvincular',
      destrutivo: true,
    );
    if (confirmou) await _desvincular(compras);
  }

  Future<void> _acoesCompra(Transacao x) async {
    final acao = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!x.ehParcela && !x.ehDividida)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar (data, valor, descrição)'),
                onTap: () => Navigator.of(context).pop('editar'),
              ),
            ListTile(
              leading: const Icon(Icons.link_off),
              title: const Text('Desvincular do cartão'),
              onTap: () => Navigator.of(context).pop('desvincular'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Excluir'),
              onTap: () => Navigator.of(context).pop('excluir'),
            ),
          ],
        ),
      ),
    );
    if (acao == null || !mounted) return;
    switch (acao) {
      case 'editar':
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NovaTransacaoScreen(transacao: x)));
      case 'desvincular':
        await _desvincular([x]);
      case 'excluir':
        final ok = await AppConfirmDialog.mostrar(
          context,
          titulo: 'Excluir transação?',
          mensagem: '"${x.descricao}" será removida. Essa ação não pode ser desfeita.',
          rotuloConfirmar: 'Excluir',
          destrutivo: true,
        );
        if (ok) await ref.read(excluirTransacaoUseCaseProvider).call(x.id);
    }
  }

  Future<void> _vincularSemCartao(Cartao c, PeriodoFatura periodo) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VincularComprasScreen(cartao: c, periodo: periodo)),
    );
  }

  Future<void> _pagar(Cartao c, ({int ano, int mes}) ref, double total) async {
    final pago = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _PagarFaturaScreen(cartao: c, ano: ref.ano, mes: ref.mes, sugerido: total)),
    );
    if (pago == true) recarregarPagamentos();
  }

  void recarregarPagamentos() => ref.invalidate(pagamentosFaturaProvider);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cartoes = ref.watch(cartoesProvider).valueOrNull ?? const <Cartao>[];
    final cartao = cartoes.where((c) => c.id == widget.cartaoId).firstOrNull;
    final todas = ref.watch(transacoesStreamProvider).valueOrNull ?? const <Transacao>[];
    final pagamentos = ref.watch(pagamentosFaturaProvider).valueOrNull ?? const [];

    if (cartao == null) {
      return Scaffold(backgroundColor: t.bg, appBar: AppBar(backgroundColor: t.bg), body: const SizedBox.shrink());
    }

    final hoje = DateTime.now();
    final referencia = _ref ??
        faturaAberta(diaFechamento: cartao.diaFechamento, diaVencimento: cartao.diaVencimento, hoje: hoje);
    final periodo = periodoDaFatura(
      diaFechamento: cartao.diaFechamento,
      diaVencimento: cartao.diaVencimento,
      ano: referencia.ano,
      mes: referencia.mes,
    );
    final compras = todas.where((x) => x.cartaoId == cartao.id && periodo.contem(x.data)).toList()
      ..sort((a, b) => b.data.compareTo(a.data));
    // O total é o que o banco cobra: compras (negativas) menos estornos.
    final total = -compras.fold<double>(0, (a, x) => a + x.valorCobrado);
    final paga = pagamentos.where((p) => p.cartaoId == cartao.id && p.ano == referencia.ano && p.mes == referencia.mes).firstOrNull;
    final emAberto = resumirFaturas(cartao: cartao, transacoes: todas, pagamentos: pagamentos).where((f) => f.emAberto).toList();
    final semCartao = todas.where((x) => x.cartaoId == null && x.valorCobrado < 0 && periodo.contem(x.data)).length;
    final dias = periodo.vencimento.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;

    final situacao = paga != null
        ? 'Paga em ${_data(paga.dataPagamento)} · ${formatCurrency(paga.valor)}'
        : dias < 0
            ? 'Vencida há ${-dias} ${dias == -1 ? 'dia' : 'dias'}'
            : dias == 0
                ? 'Vence hoje'
                : 'Vence em $dias ${dias == 1 ? 'dia' : 'dias'}';

    void mover(int delta) {
      final d = DateTime(referencia.ano, referencia.mes + delta);
      setState(() => _ref = (ano: d.year, mes: d.month));
    }

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Fatura ${cartao.nome}', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => mover(-1), icon: const Icon(Icons.chevron_left)),
                Text('Vencimento em ${kMesesPorExtenso[referencia.mes - 1]} de ${referencia.ano}',
                    style: TextStyle(fontWeight: FontWeight.w800, color: t.ink)),
                IconButton(onPressed: () => mover(1), icon: const Icon(Icons.chevron_right)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total da fatura', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(formatCurrency(total),
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Compras de ${_data(periodo.inicio)} a ${_data(periodo.fim.subtract(const Duration(days: 1)))}',
                      style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 13)),
                  Text('Vencimento ${_data(periodo.vencimento)} · $situacao',
                      style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (paga == null)
              FilledButton.icon(
                onPressed: () => _pagar(cartao, referencia, total),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Marcar como paga'),
              )
            else
              OutlinedButton.icon(
                onPressed: () async {
                  await ref
                      .read(desfazerPagamentoFaturaUseCaseProvider)
                      .call(cartaoId: cartao.id, ano: referencia.ano, mes: referencia.mes);
                  recarregarPagamentos();
                },
                icon: const Icon(Icons.undo),
                label: const Text('Desfazer pagamento'),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReconciliationScreen())),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Comparar com o extrato da fatura'),
            ),
            if (semCartao > 0) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _vincularSemCartao(cartao, periodo),
                icon: const Icon(Icons.link),
                label: Text('Vincular $semCartao compras sem cartão'),
              ),
            ],
            const SizedBox(height: 16),
            if (emAberto.isNotEmpty) ...[
              Text('Faturas em aberto', style: TextStyle(fontWeight: FontWeight.w800, color: t.ink)),
              const SizedBox(height: 4),
              for (final f in emAberto)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onTap: () => setState(() => _ref = (ano: f.ano, mes: f.mes)),
                  leading: Icon(
                    f.vencidaEm(hoje) ? Icons.warning_amber_rounded : Icons.schedule,
                    color: f.vencidaEm(hoje) ? t.neg : t.sub,
                  ),
                  title: Text('${kMesesPorExtenso[f.mes - 1]} de ${f.ano}', style: TextStyle(color: t.ink)),
                  subtitle: Text(
                    '${f.vencidaEm(hoje) ? 'Venceu' : 'Vence'} em ${_data(f.periodo.vencimento)}',
                    style: TextStyle(color: f.vencidaEm(hoje) ? t.neg : t.sub),
                  ),
                  trailing: Text(formatCurrency(f.total), style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
                ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: Text('Compras (${compras.length})', style: TextStyle(fontWeight: FontWeight.w800, color: t.ink)),
                ),
                if (compras.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _desvincularTodas(compras),
                    icon: const Icon(Icons.link_off, size: 18),
                    label: const Text('Desvincular todas'),
                  ),
              ],
            ),
            Text('Toque numa compra para editar, desvincular ou excluir.', style: TextStyle(color: t.sub, fontSize: 12)),
            const SizedBox(height: 4),
            if (compras.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Nenhuma compra neste período.', style: TextStyle(color: t.sub)),
              ),
            for (final x in compras)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                onTap: () => _acoesCompra(x),
                title: Text(x.descricao, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: t.ink)),
                subtitle: Text(_data(x.data), style: TextStyle(color: t.sub)),
                trailing: Text(formatCurrency(x.valorCobrado.abs()),
                    style: TextStyle(color: x.valorCobrado < 0 ? t.neg : t.pos, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}

class _PagarFaturaScreen extends ConsumerStatefulWidget {
  const _PagarFaturaScreen({required this.cartao, required this.ano, required this.mes, required this.sugerido});

  final Cartao cartao;
  final int ano;
  final int mes;
  final double sugerido;

  @override
  ConsumerState<_PagarFaturaScreen> createState() => _PagarFaturaScreenState();
}

class _PagarFaturaScreenState extends ConsumerState<_PagarFaturaScreen> {
  late final _valor = TextEditingController(text: widget.sugerido.toStringAsFixed(2).replaceAll('.', ','));
  DateTime _data = DateTime.now();
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final v = double.tryParse(_valor.text.trim().replaceAll(',', '.'));
    if (v == null) {
      setState(() => _erro = 'Informe o valor pago.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final r = await ref.read(registrarPagamentoFaturaUseCaseProvider).call(
          FaturaPaga(cartaoId: widget.cartao.id, ano: widget.ano, mes: widget.mes, valor: v, dataPagamento: _data),
        );
    if (!mounted) return;
    r.match(
      (f) => setState(() {
        _erro = f.message;
        _salvando = false;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Pagar fatura', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text('Marca a fatura do ${widget.cartao.nome} como paga. Não cria uma despesa nova: as compras já estão nos seus gastos.',
                  style: TextStyle(color: t.sub, fontSize: 13)),
              TextField(
                controller: _valor,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Valor pago', prefixText: 'R\$ ', errorText: _erro),
              ),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _data,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setState(() => _data = d);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Data do pagamento'),
                  child: Text('${_data.day.toString().padLeft(2, '0')}/${_data.month.toString().padLeft(2, '0')}/${_data.year}'),
                ),
              ),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                style: FilledButton.styleFrom(
                  backgroundColor: t.hero,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_salvando ? 'Salvando...' : 'Confirmar pagamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
