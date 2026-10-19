import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/presentation/providers/conta_providers.dart';

String _formatarData(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Cadastro e edição de conta a pagar. Com [existente], edita; sem, cria.
class ContaFormScreen extends ConsumerStatefulWidget {
  const ContaFormScreen({
    this.existente,
    this.sugestaoDescricao,
    this.sugestaoValor,
    this.sugestaoVencimento,
    this.sugestaoRecorrencia,
    super.key,
  });

  final ContaAPagar? existente;

  /// Pré-preenchimento ao criar a partir de outra tela (ex.: gasto recorrente).
  final String? sugestaoDescricao;
  final double? sugestaoValor;
  final DateTime? sugestaoVencimento;
  final RecorrenciaConta? sugestaoRecorrencia;

  @override
  ConsumerState<ContaFormScreen> createState() => _ContaFormScreenState();
}

class _ContaFormScreenState extends ConsumerState<ContaFormScreen> {
  late final _descricao = TextEditingController(text: widget.existente?.descricao ?? widget.sugestaoDescricao ?? '');
  late final _valor = TextEditingController(
    text: (widget.existente?.valor ?? widget.sugestaoValor)?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
  );
  late DateTime _vencimento =
      widget.existente?.vencimento ?? widget.sugestaoVencimento ?? DateTime.now().add(const Duration(days: 7));
  late RecorrenciaConta _recorrencia =
      widget.existente?.recorrencia ?? widget.sugestaoRecorrencia ?? RecorrenciaConta.nenhuma;
  late String _categoria = widget.existente?.categoria ?? '';
  late int _diasAntes = widget.existente?.diasAntesLembrete ?? 1;
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _vencimento,
      firstDate: DateTime(hoje.year - 1),
      lastDate: DateTime(hoje.year + 10),
    );
    if (escolhida != null) setState(() => _vencimento = escolhida);
  }

  Future<void> _salvar() async {
    final valor = double.tryParse(_valor.text.trim().replaceAll('.', '').replaceAll(',', '.'));
    if (valor == null) {
      setState(() => _erro = 'Informe um valor válido.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });

    final existente = widget.existente;
    final resultado = existente == null
        ? await ref.read(criarContaUseCaseProvider)(
            descricao: _descricao.text,
            valor: valor,
            vencimento: _vencimento,
            categoria: _categoria,
            recorrencia: _recorrencia,
            diasAntesLembrete: _diasAntes,
          )
        : await ref.read(editarContaUseCaseProvider)(
            (soDia(existente.vencimento) == soDia(_vencimento) ? existente : existente.reagendada(_vencimento))
                .copyWith(
              descricao: _descricao.text,
              valor: valor,
              categoria: _categoria,
              recorrencia: _recorrencia,
              diasAntesLembrete: _diasAntes,
            ),
          );

    if (!mounted) return;
    resultado.fold(
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
    final categorias = kCategorias.where((c) => c != 'Renda').toList();

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: t.ink),
        title: Text(editando ? 'Editar conta' : 'Nova conta', style: TextStyle(color: t.ink)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              TextField(
                controller: _descricao,
                decoration: const InputDecoration(labelText: 'Descrição', hintText: 'Ex.: Aluguel'),
              ),
              TextField(
                controller: _valor,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
              ),
              InkWell(
                onTap: _escolherData,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Vencimento'),
                  child: Text(_formatarData(_vencimento)),
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: categorias.contains(_categoria) ? _categoria : null,
                decoration: const InputDecoration(labelText: 'Categoria (opcional)'),
                items: [for (final c in categorias) DropdownMenuItem(value: c, child: Text(c))],
                onChanged: (c) => setState(() => _categoria = c ?? ''),
              ),
              DropdownButtonFormField<RecorrenciaConta>(
                initialValue: _recorrencia,
                decoration: const InputDecoration(labelText: 'Repetição'),
                items: [for (final r in RecorrenciaConta.values) DropdownMenuItem(value: r, child: Text(r.rotulo))],
                onChanged: (r) => setState(() => _recorrencia = r ?? RecorrenciaConta.nenhuma),
              ),
              DropdownButtonFormField<int>(
                initialValue: _diasAntes,
                decoration: const InputDecoration(labelText: 'Lembrar'),
                items: [
                  for (final d in const [0, 1, 2, 3, 7])
                    DropdownMenuItem(value: d, child: Text(d == 0 ? 'No dia' : '$d ${d == 1 ? 'dia' : 'dias'} antes')),
                ],
                onChanged: (d) => setState(() => _diasAntes = d ?? 1),
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
                child: Text(_salvando ? 'Salvando...' : 'Salvar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
