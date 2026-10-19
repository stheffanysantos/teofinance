import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/presentation/providers/conta_providers.dart';

/// Confirma o pagamento: o valor real (pode diferir do esperado) e a categoria
/// da despesa que será criada.
class PagarContaSheet extends ConsumerStatefulWidget {
  const PagarContaSheet({required this.conta, super.key});

  final ContaAPagar conta;

  @override
  ConsumerState<PagarContaSheet> createState() => _PagarContaSheetState();
}

class _PagarContaSheetState extends ConsumerState<PagarContaSheet> {
  late final _valor = TextEditingController(text: widget.conta.valor.toStringAsFixed(2).replaceAll('.', ','));
  late String _categoria = widget.conta.categoria;
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _pagar() async {
    final valor = double.tryParse(_valor.text.trim().replaceAll('.', '').replaceAll(',', '.'));
    if (valor == null) {
      setState(() => _erro = 'Informe o valor pago.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });

    final r = await ref.read(marcarContaComoPagaUseCaseProvider)(
      conta: widget.conta,
      valorPago: valor,
      categoria: _categoria,
    );
    if (!mounted) return;
    r.fold(
      (falha) => setState(() {
        _erro = falha.message;
        _salvando = false;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final categorias = kCategorias.where((c) => c != 'Renda').toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text('Pagar ${widget.conta.descricao}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.ink)),
          Text(
            'Cria uma despesa com a data de hoje. Se o valor veio diferente do esperado, ajuste abaixo.',
            style: TextStyle(fontSize: 13, color: t.sub),
          ),
          TextField(
            controller: _valor,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Valor pago', prefixText: 'R\$ ', errorText: _erro),
          ),
          DropdownButtonFormField<String>(
            initialValue: categorias.contains(_categoria) ? _categoria : null,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: [for (final c in categorias) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (c) => setState(() => _categoria = c ?? ''),
          ),
          FilledButton(
            onPressed: _salvando ? null : _pagar,
            child: Text(_salvando ? 'Registrando...' : 'Confirmar pagamento'),
          ),
        ],
      ),
    );
  }
}
