import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/categorias.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/transacao_providers.dart';

/// Cadastro manual de transação — item 4 do MVP
/// (`.claude/plans/MVP.md`), complementar à importação de extrato.
class NovaTransacaoScreen extends ConsumerStatefulWidget {
  const NovaTransacaoScreen({super.key});

  @override
  ConsumerState<NovaTransacaoScreen> createState() => _NovaTransacaoScreenState();
}

class _NovaTransacaoScreenState extends ConsumerState<NovaTransacaoScreen> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _data = DateTime.now();
  bool _isDespesa = true;
  String _categoria = '';
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final valorDigitado = double.tryParse(_valorController.text.replaceAll(',', '.'));
    if (valorDigitado == null) {
      setState(() => _erro = 'Informe um valor numérico válido.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final valor = _isDespesa ? -valorDigitado.abs() : valorDigitado.abs();
    final resultado = await ref.read(criarTransacaoUseCaseProvider).call(
          descricao: _descricaoController.text,
          valor: valor,
          data: _data,
          categoria: _categoria,
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

  Future<void> _escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (escolhida != null) setState(() => _data = escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final categorias = kCategorias;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        title: Text('Nova transação', style: TextStyle(color: t.ink)),
        iconTheme: IconThemeData(color: t.ink),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TipoChip(
                      label: 'Despesa',
                      selecionado: _isDespesa,
                      onTap: () => setState(() => _isDespesa = true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TipoChip(
                      label: 'Receita',
                      selecionado: !_isDespesa,
                      onTap: () => setState(() => _isDespesa = false),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              TextField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
              ),
              InkWell(
                onTap: _escolherData,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Data'),
                  child: Text(
                    '${_data.day.toString().padLeft(2, '0')}/'
                    '${_data.month.toString().padLeft(2, '0')}/${_data.year}',
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: _categoria.isEmpty ? null : _categoria,
                decoration: const InputDecoration(labelText: 'Categoria (opcional)'),
                items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _categoria = v ?? ''),
              ),
              if (_erro != null)
                Text(_erro!, style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600)),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                style: FilledButton.styleFrom(
                  backgroundColor: t.hero,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_salvando ? 'Salvando...' : 'Salvar transação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipoChip extends StatelessWidget {
  const _TipoChip({required this.label, required this.selecionado, required this.onTap});

  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selecionado ? t.hero : t.track,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selecionado ? Colors.white : t.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
