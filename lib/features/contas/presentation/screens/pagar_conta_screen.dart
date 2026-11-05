import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/features/categoria/presentation/providers/categoria_providers.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_form_page.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/presentation/providers/conta_providers.dart';

/// Confirma o pagamento: o valor real (pode diferir do esperado) e a categoria
/// da despesa que será criada.
class PagarContaScreen extends ConsumerStatefulWidget {
  const PagarContaScreen({required this.conta, super.key});

  final ContaAPagar conta;

  @override
  ConsumerState<PagarContaScreen> createState() => _PagarContaScreenState();
}

class _PagarContaScreenState extends ConsumerState<PagarContaScreen> {
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
    final categorias = ref.watch(categoriasProvider).where((c) => c != 'Renda').toList();

    return AppFormPage(
      titulo: 'Pagar ${widget.conta.descricao}',
      children: [
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
    );
  }
}
