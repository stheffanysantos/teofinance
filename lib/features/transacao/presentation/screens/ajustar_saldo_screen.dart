import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/widgets/app_form_page.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

/// Informa o saldo real da conta; o app cria um lançamento de ajuste para o
/// "Saldo total" bater com ele, sem alterar receitas nem despesas.
class AjustarSaldoScreen extends ConsumerStatefulWidget {
  const AjustarSaldoScreen({super.key});

  @override
  ConsumerState<AjustarSaldoScreen> createState() => _AjustarSaldoScreenState();
}

class _AjustarSaldoScreenState extends ConsumerState<AjustarSaldoScreen> {
  final _valor = TextEditingController();
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  double? _lerValor() {
    var texto = _valor.text.trim().replaceAll(' ', '');
    if (texto.isEmpty) return null;
    // aceita "1.234,56" e "1234,56"
    if (texto.contains(',')) texto = texto.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(texto);
  }

  Future<void> _salvar() async {
    final saldo = _lerValor();
    if (saldo == null) {
      setState(() => _erro = 'Informe o saldo atual da sua conta.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final r = await ref.read(ajustarSaldoUseCaseProvider).call(saldo);
    if (!mounted) return;
    r.match(
      (f) => setState(() {
        _erro = f.message;
        _salvando = false;
      }),
      (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final transacoes = ref.watch(transacoesStreamProvider).valueOrNull ?? const [];
    final atual = transacoes.fold<double>(0, (a, x) => a + x.valorNoSaldo);
    final desejado = _lerValor();

    return AppFormPage(
      titulo: 'Ajustar saldo',
      children: [
        Text(
          'O saldo do app soma só o que você lançou ou importou, sem o dinheiro que já estava na conta. '
          'Informe quanto você tem hoje e o app cria um lançamento de ajuste para os dois baterem. '
          'Esse ajuste não conta como receita nem como despesa.',
          style: TextStyle(color: t.sub, fontSize: 13.5, height: 1.4),
        ),
        Text('Saldo atual no app: ${formatCurrency(atual)}', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
        TextField(
          controller: _valor,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: InputDecoration(labelText: 'Saldo real da conta hoje', prefixText: 'R\$ ', errorText: _erro),
        ),
        if (desejado != null)
          Text(
            'Ajuste de ${formatCurrency(desejado - atual, comSinal: true)} no saldo.',
            style: TextStyle(color: t.sub, fontSize: 13),
          ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          style: FilledButton.styleFrom(
            backgroundColor: t.hero,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(_salvando ? 'Salvando...' : 'Ajustar saldo'),
        ),
      ],
    );
  }
}
