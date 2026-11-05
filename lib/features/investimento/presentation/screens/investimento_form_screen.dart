import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/investimento/presentation/providers/investimento_providers.dart';

/// Cadastro e edição manual de um investimento.
class InvestimentoFormScreen extends ConsumerStatefulWidget {
  const InvestimentoFormScreen({this.existente, super.key});

  final Investimento? existente;

  @override
  ConsumerState<InvestimentoFormScreen> createState() => _InvestimentoFormScreenState();
}

class _InvestimentoFormScreenState extends ConsumerState<InvestimentoFormScreen> {
  late final _nome = TextEditingController(text: widget.existente?.nome ?? '');
  late final _investido = TextEditingController(text: _fmt(widget.existente?.valorInvestido));
  late final _atual = TextEditingController(text: _fmt(widget.existente?.valorAtual));
  late final _obs = TextEditingController(text: widget.existente?.observacao ?? '');
  late TipoInvestimento _tipo = widget.existente?.tipo ?? TipoInvestimento.rendaFixa;
  late DateTime _data = widget.existente?.dataAplicacao ?? DateTime.now();
  bool _salvando = false;
  String? _erro;

  static String _fmt(double? v) => v == null ? '' : v.toStringAsFixed(2).replaceAll('.', ',');

  @override
  void dispose() {
    _nome.dispose();
    _investido.dispose();
    _atual.dispose();
    _obs.dispose();
    super.dispose();
  }

  double? _num(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  Future<void> _escolherData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _data = d);
  }

  Future<void> _salvar() async {
    final investido = _num(_investido.text);
    if (investido == null) {
      setState(() => _erro = 'Informe o valor investido.');
      return;
    }
    // Sem valor atual informado, assume que vale o que foi aplicado.
    final atual = _atual.text.trim().isEmpty ? investido : _num(_atual.text);
    if (atual == null) {
      setState(() => _erro = 'Valor atual inválido.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });
    final resultado = await ref.read(salvarInvestimentoUseCaseProvider).call(
          id: widget.existente?.id,
          nome: _nome.text,
          tipo: _tipo,
          valorInvestido: investido,
          valorAtual: atual,
          dataAplicacao: _data,
          observacao: _obs.text,
        );
    if (!mounted) return;
    resultado.match(
      (falha) => setState(() {
        _erro = falha.message;
        _salvando = false;
      }),
      (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final editando = widget.existente != null;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text(editando ? 'Editar investimento' : 'Novo investimento', style: TextStyle(color: t.ink)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              TextField(controller: _nome, decoration: const InputDecoration(labelText: 'Nome (ex.: CDB Banco X)')),
              DropdownButtonFormField<TipoInvestimento>(
                initialValue: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: [
                  for (final tipo in TipoInvestimento.values) DropdownMenuItem(value: tipo, child: Text(tipo.rotulo)),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? _tipo),
              ),
              TextField(
                controller: _investido,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor investido', prefixText: 'R\$ '),
              ),
              TextField(
                controller: _atual,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor atual (opcional)',
                  prefixText: 'R\$ ',
                  helperText: 'Em branco = igual ao valor investido',
                ),
              ),
              InkWell(
                onTap: _escolherData,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Data da aplicação'),
                  child: Text(
                    '${_data.day.toString().padLeft(2, '0')}/${_data.month.toString().padLeft(2, '0')}/${_data.year}',
                  ),
                ),
              ),
              TextField(controller: _obs, decoration: const InputDecoration(labelText: 'Observação (opcional)')),
              if (_erro != null) Text(_erro!, style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600)),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                style: FilledButton.styleFrom(
                  backgroundColor: t.hero,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_salvando ? 'Salvando...' : (editando ? 'Salvar alterações' : 'Salvar investimento')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
