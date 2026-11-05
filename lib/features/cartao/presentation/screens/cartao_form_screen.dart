import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_form_page.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/presentation/providers/cartao_providers.dart';
import 'package:teofinance/features/lembrete/presentation/providers/lembrete_providers.dart';

/// Cadastro e edição de um cartão de crédito.
class CartaoFormScreen extends ConsumerStatefulWidget {
  const CartaoFormScreen({this.existente, super.key});

  final Cartao? existente;

  @override
  ConsumerState<CartaoFormScreen> createState() => _CartaoFormScreenState();
}

class _CartaoFormScreenState extends ConsumerState<CartaoFormScreen> {
  late final _nome = TextEditingController(text: widget.existente?.nome ?? '');
  late final _limite = TextEditingController(
    text: widget.existente?.limite?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
  );
  late int _fechamento = widget.existente?.diaFechamento ?? 25;
  late int _vencimento = widget.existente?.diaVencimento ?? 5;
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _limite.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final texto = _limite.text.trim();
    final limite = texto.isEmpty ? null : double.tryParse(texto.replaceAll('.', '').replaceAll(',', '.'));
    if (texto.isNotEmpty && limite == null) {
      setState(() => _erro = 'Limite inválido.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final base = widget.existente ?? const Cartao(id: '', nome: '', diaFechamento: 1, diaVencimento: 1);
    final resultado = await ref.read(salvarCartaoUseCaseProvider).call(
          Cartao(id: base.id, nome: _nome.text, diaFechamento: _fechamento, diaVencimento: _vencimento, limite: limite),
        );
    ref.invalidate(lembretesPersonalizadosProvider);
    if (!mounted) return;
    resultado.match(
      (falha) => setState(() {
        _erro = falha.message;
        _salvando = false;
      }),
      (_) => Navigator.of(context).pop(),
    );
  }

  Widget _dia(String rotulo, int valor, ValueChanged<int> aoMudar) {
    return DropdownButtonFormField<int>(
      initialValue: valor,
      decoration: InputDecoration(labelText: rotulo),
      items: [for (var d = 1; d <= 31; d++) DropdownMenuItem(value: d, child: Text('dia $d'))],
      onChanged: (v) => setState(() => aoMudar(v ?? valor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppFormPage(
      titulo: widget.existente == null ? 'Novo cartão' : 'Editar cartão',
      children: [
        TextField(controller: _nome, decoration: const InputDecoration(labelText: 'Nome (ex.: Nubank)')),
        _dia('A fatura fecha', _fechamento, (v) => _fechamento = v),
        _dia('A fatura vence', _vencimento, (v) => _vencimento = v),
        Text(
          'Ao salvar, criamos em Meus lembretes um aviso para o fechamento e outro para o vencimento.',
          style: TextStyle(color: t.sub, fontSize: 12.5),
        ),
        TextField(
          controller: _limite,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Limite (opcional)', prefixText: 'R\$ '),
        ),
        if (_erro != null) Text(_erro!, style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600)),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          style: FilledButton.styleFrom(
            backgroundColor: t.hero,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(_salvando ? 'Salvando...' : 'Salvar cartão'),
        ),
      ],
    );
  }
}
