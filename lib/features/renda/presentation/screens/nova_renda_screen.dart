import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/renda.dart';
import '../providers/renda_providers.dart';

/// Cadastro de renda fixa (com recorrência) ou variável — item 5 do MVP
/// (`.claude/plans/MVP.md`).
class NovaRendaScreen extends ConsumerStatefulWidget {
  const NovaRendaScreen({super.key});

  @override
  ConsumerState<NovaRendaScreen> createState() => _NovaRendaScreenState();
}

class _NovaRendaScreenState extends ConsumerState<NovaRendaScreen> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  TipoRenda _tipo = TipoRenda.fixa;
  RecorrenciaRenda _recorrencia = RecorrenciaRenda.mensal;
  DateTime _data = DateTime.now();
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
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

  Future<void> _salvar() async {
    final valor = double.tryParse(_valorController.text.replaceAll(',', '.'));
    if (valor == null) {
      setState(() => _erro = 'Informe um valor numérico válido.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final resultado = await ref.read(criarRendaUseCaseProvider).call(
          descricao: _descricaoController.text,
          valor: valor,
          tipo: _tipo,
          dataRecebimento: _data,
          recorrencia: _tipo == TipoRenda.fixa ? _recorrencia : null,
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
    final isFixa = _tipo == TipoRenda.fixa;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        title: Text('Nova renda', style: TextStyle(color: t.ink)),
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
                spacing: 10,
                children: [
                  Expanded(
                    child: _TipoChip(
                      label: 'Fixa',
                      selecionado: isFixa,
                      onTap: () => setState(() => _tipo = TipoRenda.fixa),
                    ),
                  ),
                  Expanded(
                    child: _TipoChip(
                      label: 'Variável',
                      selecionado: !isFixa,
                      onTap: () => setState(() => _tipo = TipoRenda.variavel),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _descricaoController,
                decoration: InputDecoration(
                  labelText: 'Origem',
                  hintText: isFixa ? 'Ex.: Salário · Empresa Alfa' : 'Ex.: Freela design',
                ),
              ),
              TextField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
              ),
              if (isFixa)
                DropdownButtonFormField<RecorrenciaRenda>(
                  initialValue: _recorrencia,
                  decoration: const InputDecoration(labelText: 'Recorrência'),
                  items: const [
                    DropdownMenuItem(value: RecorrenciaRenda.semanal, child: Text('Semanal')),
                    DropdownMenuItem(value: RecorrenciaRenda.mensal, child: Text('Mensal')),
                    DropdownMenuItem(value: RecorrenciaRenda.anual, child: Text('Anual')),
                  ],
                  onChanged: (v) => v != null ? setState(() => _recorrencia = v) : null,
                ),
              InkWell(
                onTap: _escolherData,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: isFixa ? 'Próximo recebimento' : 'Data do recebimento',
                  ),
                  child: Text(
                    '${_data.day.toString().padLeft(2, '0')}/'
                    '${_data.month.toString().padLeft(2, '0')}/${_data.year}',
                  ),
                ),
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
                child: Text(_salvando ? 'Salvando...' : 'Salvar renda'),
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
          style: TextStyle(color: selecionado ? Colors.white : t.ink, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
