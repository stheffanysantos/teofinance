import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_form_page.dart';
import 'package:teofinance/features/meta/domain/entities/meta.dart';
import 'package:teofinance/features/meta/presentation/providers/meta_providers.dart';

/// Registra um aporte (valor guardado) numa meta.
class AporteMetaScreen extends ConsumerStatefulWidget {
  const AporteMetaScreen({required this.meta, super.key});

  final Meta meta;

  @override
  ConsumerState<AporteMetaScreen> createState() => _AporteMetaScreenState();
}

class _AporteMetaScreenState extends ConsumerState<AporteMetaScreen> {
  final _valor = TextEditingController();
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final v = double.tryParse(_valor.text.trim().replaceAll(',', '.'));
    if (v == null || v <= 0) {
      setState(() => _erro = 'Informe um valor maior que zero.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final resultado = await ref.read(aportarMetaUseCaseProvider).call(id: widget.meta.id, valor: v);
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
      titulo: 'Registrar aporte',
      children: [
        Text(widget.meta.nome, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.ink)),
        TextField(
          controller: _valor,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Valor', prefixText: 'R\$ ', errorText: _erro),
          onSubmitted: (_) => _salvar(),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          style: FilledButton.styleFrom(
            backgroundColor: t.hero,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(_salvando ? 'Salvando...' : 'Confirmar aporte'),
        ),
      ],
    );
  }
}
