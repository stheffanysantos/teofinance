import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transacao/domain/entities/transacao.dart';
import '../providers/parcelamento_providers.dart';

/// Modal para o usuário parcelar uma transação existente.
/// Exibe a transação, um slider para escolher número de parcelas,
/// preview do valor por parcela, e botão para parcelar.
class ParcelarTransacaoScreen extends ConsumerStatefulWidget {
  final Transacao transacao;
  final VoidCallback? onSuccess;

  const ParcelarTransacaoScreen({
    required this.transacao,
    this.onSuccess,
  });

  @override
  ConsumerState<ParcelarTransacaoScreen> createState() =>
      _ParcelarTransacaoScreenState();
}

class _ParcelarTransacaoScreenState extends ConsumerState<ParcelarTransacaoScreen> {
  late int _numeroParcelas = 2;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(parcelamentoNotifierProvider.notifier);
    final state = ref.watch(parcelamentoNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcelar Compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Resumo da transação original
            Card(
              child: ListTile(
                title: Text(widget.transacao.descricao),
                subtitle: Text(widget.transacao.categoria),
                trailing: Text(
                  'R\$ ${widget.transacao.valor.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Seleção de número de parcelas
            Text(
              'Número de parcelas: $_numeroParcelas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _numeroParcelas.toDouble(),
              min: 2,
              max: 12,
              divisions: 10,
              label: '$_numeroParcelas',
              onChanged: (value) => setState(() => _numeroParcelas = value.toInt()),
            ),
            const SizedBox(height: 16),

            // Preview das parcelas
            Card(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      'Valor por parcela',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'R\$ ${(widget.transacao.valor / _numeroParcelas).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // Mensagem de erro, se houver
            if (state.erro != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      state.erro!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),

            // Botão parcelar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        await notifier.criarParcelamento(
                          transacaoId: widget.transacao.id,
                          totalOriginal: widget.transacao.valor,
                          numeroParcelas: _numeroParcelas,
                          dataPrimeira: DateTime.now(),
                        );

                        if (!mounted) return;

                        if (state.erro == null) {
                          widget.onSuccess?.call();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transação parcelada com sucesso!'),
                            ),
                          );
                        }
                      },
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Parcelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
