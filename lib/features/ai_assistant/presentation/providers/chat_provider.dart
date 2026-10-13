import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mensagem de chat do assistente local.
///
/// TODO(fase-4): `reply()` hoje é uma resposta mock baseada em palavras-chave.
/// Substituir pela inferência real via Gemma/MediaPipe quando
/// `ai-assistant-engineer` implementar `features/ai_assistant/data/`. A
/// fronteira de privacidade já modelada aqui (toda resposta é `isLocal: true`,
/// sem nenhuma chamada de rede) deve ser preservada: ver
/// `.claude/rules/security.md`.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    this.showMonthlyStat = false,
    this.isLocal = false,
  });

  final String text;
  final bool isUser;
  final bool showMonthlyStat;
  final bool isLocal;
}

const kSuggestionChips = ['Gastos com mercado', 'Como está minha reserva?', 'Resumo do mês'];

class ChatState {
  const ChatState({required this.messages, this.draft = ''});

  final List<ChatMessage> messages;
  final String draft;

  ChatState copyWith({List<ChatMessage>? messages, String? draft}) {
    return ChatState(messages: messages ?? this.messages, draft: draft ?? this.draft);
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return const ChatState(
      messages: [
        ChatMessage(text: 'Quanto gastei com delivery esse mês?', isUser: true),
        ChatMessage(
          text:
              'Você gastou R\$ 412,80 com delivery em outubro, em 14 pedidos. '
              'É 8% a mais que em setembro.',
          isUser: false,
          showMonthlyStat: true,
          isLocal: true,
        ),
      ],
    );
  }

  void setDraft(String value) => state = state.copyWith(draft: value);

  void send([String? text]) {
    final question = (text ?? state.draft).trim();
    if (question.isEmpty) return;

    state = state.copyWith(
      draft: '',
      messages: [
        ...state.messages,
        ChatMessage(text: question, isUser: true),
        ChatMessage(text: _reply(question), isUser: false, isLocal: true),
      ],
    );
  }

  String _reply(String question) {
    final q = question.toLowerCase();
    if (q.contains('merc')) {
      return 'Em mercado você gastou R\$ 1.140 este mês, 57% do limite de R\$ 2.000.';
    }
    if (q.contains('meta') || q.contains('reserva')) {
      return 'Sua reserva de emergência está em 68%: R\$ 13.600 de R\$ 20.000. '
          'No ritmo atual, você chega lá em dezembro de 2026.';
    }
    return 'Analisei suas transações de outubro: você gastou R\$ 4.920 até agora, '
        '72% do orçamento do mês.';
  }
}
