import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/periodo_fatura.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

String _data(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Escolhe quais despesas sem cartão passam a pertencer ao [cartao]. Começa
/// com as do período da fatura em tela, todas marcadas.
class VincularComprasScreen extends ConsumerStatefulWidget {
  const VincularComprasScreen({required this.cartao, required this.periodo, super.key});

  final Cartao cartao;
  final PeriodoFatura periodo;

  @override
  ConsumerState<VincularComprasScreen> createState() => _VincularComprasScreenState();
}

class _VincularComprasScreenState extends ConsumerState<VincularComprasScreen> {
  final _marcadas = <String>{};
  bool _todosPeriodos = false;
  bool _iniciou = false;
  bool _salvando = false;

  List<Transacao> _candidatas(List<Transacao> todas) {
    return todas
        .where((x) => x.cartaoId == null && x.valorCobrado < 0 && (_todosPeriodos || widget.periodo.contem(x.data)))
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  Future<void> _vincular() async {
    setState(() => _salvando = true);
    await ref.read(transacaoRepositoryProvider).vincularCartao(ids: _marcadas.toList(), cartaoId: widget.cartao.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final todas = ref.watch(transacoesStreamProvider).valueOrNull ?? const <Transacao>[];
    final lista = _candidatas(todas);

    // Primeira vez: tudo marcado.
    if (!_iniciou && todas.isNotEmpty) {
      _iniciou = true;
      _marcadas.addAll(lista.map((x) => x.id));
    }
    _marcadas.removeWhere((id) => !lista.any((x) => x.id == id));

    final totalMarcado = lista.where((x) => _marcadas.contains(x.id)).fold<double>(0, (a, x) => a + x.valorCobrado.abs());
    final todasMarcadas = lista.isNotEmpty && _marcadas.length == lista.length;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text('Vincular ao ${widget.cartao.nome}', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SwitchListTile(
              value: _todosPeriodos,
              onChanged: (v) => setState(() {
                _todosPeriodos = v;
                _iniciou = false;
                _marcadas.clear();
              }),
              title: const Text('Incluir de todos os períodos'),
              subtitle: Text(
                _todosPeriodos
                    ? 'Todas as despesas sem cartão'
                    : 'Só de ${_data(widget.periodo.inicio)} a ${_data(widget.periodo.fim.subtract(const Duration(days: 1)))}',
                style: TextStyle(color: t.sub),
              ),
            ),
            CheckboxListTile(
              value: todasMarcadas,
              onChanged: lista.isEmpty
                  ? null
                  : (v) => setState(() {
                        if (v == true) {
                          _marcadas.addAll(lista.map((x) => x.id));
                        } else {
                          _marcadas.clear();
                        }
                      }),
              title: Text('Selecionar todas (${lista.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const Divider(height: 1),
            Expanded(
              child: lista.isEmpty
                  ? Center(child: Text('Nenhuma despesa sem cartão aqui.', style: TextStyle(color: t.sub)))
                  : ListView(
                      children: [
                        for (final x in lista)
                          CheckboxListTile(
                            value: _marcadas.contains(x.id),
                            onChanged: (v) => setState(() => v == true ? _marcadas.add(x.id) : _marcadas.remove(x.id)),
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(x.descricao, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(_data(x.data)),
                            secondary: Text(formatCurrency(x.valorCobrado.abs()),
                                style: TextStyle(color: t.neg, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _salvando || _marcadas.isEmpty ? null : _vincular,
                style: FilledButton.styleFrom(
                  backgroundColor: t.hero,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_marcadas.isEmpty
                    ? 'Selecione as compras'
                    : 'Vincular ${_marcadas.length} (${formatCurrency(totalMarcado)})'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
