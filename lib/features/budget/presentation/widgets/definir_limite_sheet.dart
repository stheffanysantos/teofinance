import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_confirm_dialog.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/presentation/providers/budget_providers.dart';

/// Folha para criar ou editar o limite de uma categoria. Com [existente],
/// a categoria fica fixa e a folha oferece excluir o limite.
class DefinirLimiteSheet extends ConsumerStatefulWidget {
  const DefinirLimiteSheet({required this.categoriasLivres, this.existente, super.key});

  /// Categorias que ainda não têm limite (usadas ao criar).
  final List<String> categoriasLivres;
  final Orcamento? existente;

  /// Categorias que podem ter limite: tudo menos a de receita.
  static List<String> categoriasOrcaveis() => kCategorias.where((c) => c != 'Renda').toList();

  @override
  ConsumerState<DefinirLimiteSheet> createState() => _DefinirLimiteSheetState();
}

class _DefinirLimiteSheetState extends ConsumerState<DefinirLimiteSheet> {
  late String? _categoria = widget.existente?.categoria ??
      (widget.categoriasLivres.isEmpty ? null : widget.categoriasLivres.first);
  late final _controller = TextEditingController(
    text: widget.existente == null ? '' : widget.existente!.limite.toStringAsFixed(2).replaceAll('.', ','),
  );
  String? _erro;
  bool _salvando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final limite = double.tryParse(_controller.text.trim().replaceAll('.', '').replaceAll(',', '.'));
    if (limite == null) {
      setState(() => _erro = 'Informe um valor válido.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });
    final result = await ref.read(definirLimiteOrcamentoUseCaseProvider)(
      categoria: _categoria ?? '',
      limite: limite,
    );
    if (!mounted) return;
    result.fold(
      (falha) => setState(() {
        _salvando = false;
        _erro = falha.message;
      }),
      (_) => Navigator.of(context).pop(),
    );
  }

  Future<void> _excluir() async {
    final confirmar = await AppConfirmDialog.mostrar(
      context,
      titulo: 'Excluir limite?',
      mensagem: 'O envelope de ${widget.existente!.categoria} deixa de existir. Suas transações não são afetadas.',
      rotuloConfirmar: 'Excluir',
      destrutivo: true,
    );
    if (!confirmar || !mounted) return;

    final result = await ref.read(excluirLimiteOrcamentoUseCaseProvider)(widget.existente!.id);
    if (!mounted) return;
    result.fold(
      (falha) => setState(() => _erro = falha.message),
      (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final editando = widget.existente != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            editando ? 'Editar limite' : 'Novo limite mensal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.ink),
          ),
          if (editando)
            Text(_categoria!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.sub))
          else if (widget.categoriasLivres.isEmpty)
            Text('Todas as categorias já têm limite.', style: TextStyle(color: t.sub))
          else
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: [
                for (final c in widget.categoriasLivres) DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (c) => setState(() => _categoria = c),
            ),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Limite por mês', prefixText: 'R\$ ', errorText: _erro),
            onSubmitted: (_) => _salvar(),
          ),
          FilledButton(
            onPressed: _salvando || _categoria == null ? null : _salvar,
            child: Text(editando ? 'Salvar' : 'Criar limite'),
          ),
          if (editando)
            TextButton(
              onPressed: _salvando ? null : _excluir,
              style: TextButton.styleFrom(foregroundColor: t.neg),
              child: const Text('Excluir limite'),
            ),
        ],
      ),
    );
  }
}
