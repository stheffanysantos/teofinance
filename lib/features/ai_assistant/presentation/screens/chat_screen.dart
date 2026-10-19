import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/modelo_ia_banner.dart';

/// Tela do Assistente IA — implementação fiel a Chat.dc.html. Toda resposta
/// é gerada localmente (ver `ResponderPerguntaUseCase`); nenhuma transação ou
/// pergunta sai do aparelho, conforme `.claude/agents/ai-assistant-engineer.md`.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _send([String? text]) {
    ref.read(chatProvider.notifier).send(text);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final chat = ref.watch(chatProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.line))),
            child: Row(
              spacing: 12,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Assistente', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: t.ink)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 5,
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: t.pos, shape: BoxShape.circle)),
                          Text(
                            'Modelo local · funciona offline',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.pos),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const ModeloIaBanner(),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Text(
                    'Hoje',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.sub),
                  ),
                ),
                const SizedBox(height: 18),
                for (var i = 0; i < chat.messages.length; i++) ...[
                  if (i > 0) const SizedBox(height: 18),
                  Align(
                    alignment: chat.messages[i].isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: ChatBubble(message: chat.messages[i]),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: t.bg,
              border: Border(top: BorderSide(color: t.line)),
            ),
            child: Column(
              spacing: 10,
              children: [
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: kSuggestionChips.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final label = kSuggestionChips[i];
                      return GestureDetector(
                        onTap: () => _send(label),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                          decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(999)),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: t.ink),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) => ref.read(chatProvider.notifier).setDraft(value),
                        onSubmitted: _send,
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: t.ink),
                        decoration: InputDecoration(
                          hintText: 'Pergunte sobre suas finanças...',
                          hintStyle: TextStyle(color: t.sub, fontWeight: FontWeight.w600),
                          filled: true,
                          fillColor: t.card,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: t.line, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: t.line, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: t.hero, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _send(),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: t.hero, borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: Icon(Icons.arrow_upward, size: 20, color: t.accent),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Suas perguntas nunca saem do aparelho',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.sub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
