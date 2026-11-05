import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/features/categoria/presentation/providers/categoria_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cartao/presentation/providers/cartao_providers.dart';
import '../../domain/entities/transacao.dart';
import '../providers/transacao_providers.dart';

/// Cadastro manual de transação — item 4 do MVP
/// (`.claude/plans/MVP.md`), complementar à importação de extrato.
class NovaTransacaoScreen extends ConsumerStatefulWidget {
  const NovaTransacaoScreen({super.key, this.transacao});

  /// Quando informada, a tela edita esta transação em vez de criar uma nova.
  final Transacao? transacao;

  @override
  ConsumerState<NovaTransacaoScreen> createState() => _NovaTransacaoScreenState();
}

class _NovaTransacaoScreenState extends ConsumerState<NovaTransacaoScreen> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _data = DateTime.now();
  bool _isDespesa = true;
  String _categoria = '';
  String? _cartaoId;
  bool _salvando = false;
  String? _erro;

  bool get _editando => widget.transacao != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transacao;
    if (t != null) {
      _descricaoController.text = t.descricao;
      _valorController.text = t.valor.abs().toStringAsFixed(2).replaceAll('.', ',');
      _data = t.data;
      _isDespesa = t.valor < 0;
      _categoria = t.categoria;
      _cartaoId = t.cartaoId;
    }
  }

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
    final cartaoId = _isDespesa ? _cartaoId : null;
    final resultado = _editando
        ? await ref.read(editarTransacaoUseCaseProvider).call(
              id: widget.transacao!.id,
              descricao: _descricaoController.text,
              valor: valor,
              data: _data,
              categoria: _categoria,
            )
        : await ref.read(criarTransacaoUseCaseProvider).call(
              descricao: _descricaoController.text,
              valor: valor,
              data: _data,
              categoria: _categoria,
            );

    if (!mounted) return;
    if (resultado.isRight()) {
      final id = _editando ? widget.transacao!.id : resultado.fold((_) => null, (r) => r is Transacao ? r.id : null);
      if (id != null && (cartaoId != null || widget.transacao?.cartaoId != null)) {
        await ref.read(transacaoRepositoryProvider).definirCartao(id: id, cartaoId: cartaoId);
      }
    }
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
    final todas = ref.watch(categoriasProvider);
    final cartoes = ref.watch(cartoesProvider).valueOrNull ?? const [];
    final categorias = [
      ...todas,
      if (_categoria.isNotEmpty && !todas.contains(_categoria)) _categoria,
    ];

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        title: Text(_editando ? 'Editar transação' : 'Nova transação', style: TextStyle(color: t.ink)),
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
              if (_isDespesa && cartoes.isNotEmpty)
                DropdownButtonFormField<String?>(
                  initialValue: cartoes.any((c) => c.id == _cartaoId) ? _cartaoId : null,
                  decoration: const InputDecoration(labelText: 'Cartão (opcional)'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Sem cartão')),
                    for (final c in cartoes) DropdownMenuItem<String?>(value: c.id, child: Text(c.nome)),
                  ],
                  onChanged: (v) => setState(() => _cartaoId = v),
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
                child: Text(_salvando ? 'Salvando...' : (_editando ? 'Salvar alterações' : 'Salvar transação')),
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
