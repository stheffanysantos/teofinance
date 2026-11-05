import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/core/widgets/app_form_page.dart';
import 'package:teofinance/features/categoria/presentation/providers/categoria_providers.dart';

/// Cadastro de uma categoria nova ou, com [nomeAtual], renomeação de uma existente.
class CategoriaFormScreen extends ConsumerStatefulWidget {
  const CategoriaFormScreen({super.key, this.nomeAtual});

  final String? nomeAtual;

  @override
  ConsumerState<CategoriaFormScreen> createState() =>
      _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends ConsumerState<CategoriaFormScreen> {
  late final _nome = TextEditingController(text: widget.nomeAtual);
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final proprias =
        ref.read(categoriasPersonalizadasProvider).valueOrNull ?? const [];
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final atual = widget.nomeAtual;
    final resultado = atual == null
        ? await ref
              .read(adicionarCategoriaUseCaseProvider)
              .call(_nome.text, existentes: proprias)
        : await ref
              .read(renomearCategoriaUseCaseProvider)
              .call(
                nomeAtual: atual,
                novoNome: _nome.text,
                existentes: proprias,
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
      titulo: widget.nomeAtual == null ? 'Nova categoria' : 'Editar categoria',
      children: [
        TextField(
          controller: _nome,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Nome da categoria',
            errorText: _erro,
          ),
          onSubmitted: (_) => _salvar(),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          style: FilledButton.styleFrom(
            backgroundColor: t.hero,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(_salvando ? 'Salvando...' : 'Salvar categoria'),
        ),
      ],
    );
  }
}
