import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/estado_modelo.dart';
import 'package:teofinance/features/ai_assistant/presentation/providers/ai_assistant_providers.dart';

/// Convida a baixar o modelo local e acompanha o download. Some quando o modelo
/// está pronto ou quando este build não tem motor de IA — o assistente responde
/// de qualquer forma.
class ModeloIaBanner extends ConsumerWidget {
  const ModeloIaBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(estadoModeloProvider).valueOrNull;
    final gerenciador = ref.read(gerenciadorModeloProvider);

    return switch (estado) {
      ModeloNaoInstalado(:final tamanhoEmMb) => _Faixa(
          mensagem: 'Baixe o modelo de IA${tamanhoEmMb == null ? '' : ' (≈ $tamanhoEmMb MB)'} para conversas '
              'mais naturais. Use o Wi-Fi: é feito uma vez só e nada seu é enviado.',
          rotuloAcao: 'Baixar',
          onAcao: gerenciador.baixar,
        ),
      ModeloBaixando(:final progresso) => _Faixa(
          mensagem: 'Baixando o modelo… ${(progresso * 100).round()}%',
          progresso: progresso,
        ),
      ModeloComErro(:final mensagem) => _Faixa(
          mensagem: 'Não foi possível baixar o modelo: $mensagem',
          rotuloAcao: 'Tentar de novo',
          onAcao: gerenciador.baixar,
          erro: true,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Faixa extends StatelessWidget {
  const _Faixa({
    required this.mensagem,
    this.rotuloAcao,
    this.onAcao,
    this.progresso,
    this.erro = false,
  });

  final String mensagem;
  final String? rotuloAcao;
  final VoidCallback? onAcao;
  final double? progresso;
  final bool erro;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
      decoration: BoxDecoration(color: t.card, border: Border(bottom: BorderSide(color: t.line))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mensagem,
                  style: TextStyle(fontSize: 12.5, color: erro ? t.neg : t.sub, height: 1.35),
                ),
              ),
              if (rotuloAcao != null) TextButton(onPressed: onAcao, child: Text(rotuloAcao!)),
            ],
          ),
          if (progresso != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(value: progresso, minHeight: 6, backgroundColor: t.line),
            ),
        ],
      ),
    );
  }
}
