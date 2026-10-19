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
