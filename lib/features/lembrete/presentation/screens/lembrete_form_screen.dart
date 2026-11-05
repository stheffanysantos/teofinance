import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_form_page.dart';
import 'package:teofinance/features/lembrete/domain/entities/lembrete_personalizado.dart';
import 'package:teofinance/features/lembrete/presentation/providers/lembrete_providers.dart';

/// Cadastro e edição de um lembrete mensal.
class LembreteFormScreen extends ConsumerStatefulWidget {
  const LembreteFormScreen({this.existente, super.key});

  final LembretePersonalizado? existente;

  @override
  ConsumerState<LembreteFormScreen> createState() => _LembreteFormScreenState();
}

class _LembreteFormScreenState extends ConsumerState<LembreteFormScreen> {
  late final _titulo = TextEditingController(text: widget.existente?.titulo ?? '');
  late TipoLembrete _tipo = widget.existente?.tipo ?? TipoLembrete.faturaFecha;
  late int _dia = widget.existente?.dia ?? 10;
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final base = widget.existente ?? const LembretePersonalizado(id: '', titulo: '', tipo: TipoLembrete.outro, dia: 1);
    final resultado = await ref.read(salvarLembreteUseCaseProvider).call(
          base.copyWith(titulo: _titulo.text, tipo: _tipo, dia: _dia),
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
    return AppFormPage(
      titulo: widget.existente == null ? 'Novo lembrete' : 'Editar lembrete',
      children: [
        TextField(
          controller: _titulo,
          decoration: const InputDecoration(labelText: 'Nome (ex.: Cartão Nubank)'),
        ),
        DropdownButtonFormField<TipoLembrete>(
          initialValue: _tipo,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Tipo'),
          items: [for (final tipo in TipoLembrete.values) DropdownMenuItem(value: tipo, child: Text(tipo.rotulo))],
          onChanged: (v) => setState(() => _tipo = v ?? _tipo),
        ),
        DropdownButtonFormField<int>(
          initialValue: _dia,
          decoration: const InputDecoration(labelText: 'Todo dia'),
          items: [for (var d = 1; d <= 31; d++) DropdownMenuItem(value: d, child: Text('$d'))],
          onChanged: (v) => setState(() => _dia = v ?? _dia),
        ),
        if (_erro != null) Text(_erro!, style: TextStyle(color: t.neg, fontSize: 13, fontWeight: FontWeight.w600)),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          style: FilledButton.styleFrom(
            backgroundColor: t.hero,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(_salvando ? 'Salvando...' : 'Salvar lembrete'),
        ),
      ],
    );
  }
}
