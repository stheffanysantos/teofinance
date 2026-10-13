import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';

/// Balão de mensagem do chat — alinhado à direita (usuário, cor de destaque)
/// ou à esquerda (assistente, cartão neutro), com cartão de estatística
/// opcional e o selo "Processado no seu aparelho".
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = message.isUser ? (isDark ? t.accent : t.hero) : t.card;
    final fg = message.isUser ? (isDark ? t.accentInk : Colors.white) : t.ink;

    return Column(
      crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            border: message.isUser ? null : Border.all(color: t.line),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(message.isUser ? 16 : 4),
              bottomRight: Radius.circular(message.isUser ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.5, color: fg),
              ),
              if (message.showMonthlyStat) ...[
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: t.line))),
                  child: Row(
                    spacing: 16,
                    children: [
                      Flexible(
                        child: _Stat(value: 'R\$ 412,80', label: 'delivery em outubro', color: fg, sub: t.sub),
                      ),
                      Flexible(
                        child: _Stat(value: '14', label: 'pedidos', color: fg, sub: t.sub),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (message.isLocal) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 11, color: t.pos),
                const SizedBox(width: 6),
                Text(
                  'Processado no seu aparelho',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.pos),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color, required this.sub});

  final String value;
  final String label;
  final Color color;
  final Color sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sub),
        ),
      ],
    );
  }
}
