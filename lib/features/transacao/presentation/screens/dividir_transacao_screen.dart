import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transacao.dart';
import '../providers/transacao_providers.dart';

/// Registra que uma compra foi dividida com outras pessoas e quanto dela é
/// do usuário — o dashboard passa a contar só a parte dele.
class DividirTransacaoScreen extends ConsumerStatefulWidget {
  const DividirTransacaoScreen({super.key, required this.transacao});

  final Transacao transacao;

  @override
  ConsumerState<DividirTransacaoScreen> createState() => _DividirTransacaoScreenState();
}

class _DividirTransacaoScreenState extends ConsumerState<DividirTransacaoScreen> {
  late final TextEditingController _pessoasController = TextEditingController(
    text: widget.transacao.divididoCom.join(', '),
  );
  late final TextEditingController _parteController = TextEditingController(
    text: widget.transacao.minhaParte?.toStringAsFixed(2) ?? '',
  );
  late bool _igual = widget.transacao.minhaParte == null;
  bool _salvando = false;
  String? _erro;

  double get _total => widget.transacao.valorCobrado.abs();

  List<String> get _pessoas => _pessoasController.text
      .split(RegExp(r'[,;\n]'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  double? get _minhaParte {
    if (_igual) {
      final participantes = _pessoas.length + 1;
      return (_total / participantes * 100).roundToDouble() / 100;
    }
    return double.tryParse(_parteController.text.replaceAll(',', '.'));
  }

  @override
  void dispose() {
    _pessoasController.dispose();
    _parteController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final parte = _minhaParte;
    if (parte == null) {
      setState(() => _erro = 'Informe um valor numérico válido para a sua parte.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final resultado = await ref.read(dividirTransacaoUseCaseProvider).call(
          id: widget.transacao.id,
          valorTotal: widget.transacao.valorCobrado,
          minhaParte: parte,
          pessoas: _pessoas,
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
    final parte = _minhaParte;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        title: Text('Dividir compra', style: TextStyle(color: t.ink)),
        iconTheme: IconThemeData(color: t.ink),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(
                widget.transacao.descricao,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: t.ink),
              ),
              Text(
                'Total cobrado: ${_total.toStringAsFixed(2)}',
                style: TextStyle(color: t.sub),
              ),
              TextField(
                controller: _pessoasController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Dividiu com quem?',
                  helperText: 'Separe os nomes por vírgula: Ana, Bruno',
                ),
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Em partes iguais')),
                  ButtonSegment(value: false, label: Text('Valor da minha parte')),
                ],
                selected: {_igual},
                onSelectionChanged: (valor) => setState(() => _igual = valor.first),
              ),
              if (!_igual)
                TextField(
                  controller: _parteController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Quanto ficou para você?'),
                ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.card,
                  border: Border.all(color: t.line),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  parte == null || _pessoas.isEmpty
                      ? 'Informe as pessoas para ver a sua parte.'
                      : 'Sua parte: ${parte.toStringAsFixed(2)} de ${_total.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.w700, color: t.ink),
                ),
              ),
              if (_erro != null) Text(_erro!, style: TextStyle(color: t.neg)),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                style: FilledButton.styleFrom(
                  backgroundColor: t.hero,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Salvar divisão'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
