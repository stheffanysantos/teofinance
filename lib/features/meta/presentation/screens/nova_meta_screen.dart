import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/meta_providers.dart';

/// Sugestões do campo Banco; o usuário pode digitar qualquer outro nome.
const _kBancos = [
  'Nubank',
  'Itaú',
  'Bradesco',
  'Banco do Brasil',
  'Caixa',
  'Santander',
  'Inter',
  'C6 Bank',
  'BTG Pactual',
  'XP Investimentos',
  'PicPay',
  'Mercado Pago',
  'Sicoob',
  'Sicredi',
];

/// Cadastro de meta de investimento — item 7 do MVP (`.claude/plans/MVP.md`).
class NovaMetaScreen extends ConsumerStatefulWidget {
  const NovaMetaScreen({super.key});

  @override
  ConsumerState<NovaMetaScreen> createState() => _NovaMetaScreenState();
}

class _NovaMetaScreenState extends ConsumerState<NovaMetaScreen> {
  final _nomeController = TextEditingController();
  final _valorAlvoController = TextEditingController();
  final _valorAtualController = TextEditingController(text: '0');
  final _bancoController = TextEditingController();
  final _bancoFocus = FocusNode();
  DateTime _prazo = DateTime.now().add(const Duration(days: 365));
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nomeController.dispose();
    _valorAlvoController.dispose();
    _valorAtualController.dispose();
    _bancoController.dispose();
    _bancoFocus.dispose();
    super.dispose();
  }

  Future<void> _escolherPrazo() async {
    final escolhido = await showDatePicker(
      context: context,
      initialDate: _prazo,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (escolhido != null) setState(() => _prazo = escolhido);
  }

  Future<void> _salvar() async {
    final valorAlvo = double.tryParse(_valorAlvoController.text.replaceAll(',', '.'));
    final valorAtual = double.tryParse(_valorAtualController.text.replaceAll(',', '.')) ?? 0;
    if (valorAlvo == null) {
      setState(() => _erro = 'Informe um valor-alvo numérico válido.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final resultado = await ref.read(criarMetaUseCaseProvider).call(
          nome: _nomeController.text,
          valorAlvo: valorAlvo,
          prazo: _prazo,
          valorAtual: valorAtual,
          banco: _bancoController.text,
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

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        title: Text('Nova meta', style: TextStyle(color: t.ink)),
        iconTheme: IconThemeData(color: t.ink),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da meta',
                  hintText: 'Ex.: Reserva de emergência',
                ),
              ),
              TextField(
                controller: _valorAlvoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor-alvo', prefixText: 'R\$ '),
              ),
              TextField(
                controller: _valorAtualController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Já guardado (opcional)',
                  prefixText: 'R\$ ',
                ),
              ),
              RawAutocomplete<String>(
                textEditingController: _bancoController,
                focusNode: _bancoFocus,
                optionsBuilder: (valor) {
                  final q = valor.text.trim().toLowerCase();
                  return _kBancos.where((b) => q.isEmpty || b.toLowerCase().contains(q));
                },
                fieldViewBuilder: (context, controller, focusNode, onSubmitted) => TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Banco (opcional)',
                    hintText: 'Onde esse dinheiro está guardado',
                    suffixIcon: Icon(Icons.account_balance_outlined),
                  ),
                ),
                optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220, maxWidth: 360),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          for (final b in options) ListTile(dense: true, title: Text(b), onTap: () => onSelected(b)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: _escolherPrazo,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Prazo'),
                  child: Text(
                    '${_prazo.day.toString().padLeft(2, '0')}/'
                    '${_prazo.month.toString().padLeft(2, '0')}/${_prazo.year}',
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
                child: Text(_salvando ? 'Salvando...' : 'Salvar meta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
