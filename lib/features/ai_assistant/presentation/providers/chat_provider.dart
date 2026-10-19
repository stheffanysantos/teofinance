import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/features/ai_assistant/presentation/providers/ai_assistant_providers.dart';

/// Mensagem de chat do assistente local. Toda resposta é `isLocal: true`: é
/// gerada no aparelho, sem chamada de rede (ver `.claude/rules/security.md`).
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isLocal = false,
  });

  final String text;
  final bool isUser;
  final bool isLocal;
}

const kSuggestionChips = ['Resumo do mês', 'Como estou no orçamento?', 'Como está minha reserva?', 'Gastos com mercado'];

class ChatState {
  const ChatState({required this.messages, this.draft = '', this.respondendo = false});

  final List<ChatMessage> messages;
  final String draft;
  final bool respondendo;

  ChatState copyWith({List<ChatMessage>? messages, String? draft, bool? respondendo}) {
    return ChatState(
      messages: messages ?? this.messages,
      draft: draft ?? this.draft,
      respondendo: respondendo ?? this.respondendo,
    );
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return const ChatState(
      messages: [
        ChatMessage(
          text: 'Oi! Posso falar sobre seus gastos do mês, orçamento e metas. '
              'Tudo é calculado aqui no seu aparelho.',
          isUser: false,
          isLocal: true,
        ),
      ],
    );
  }

  void setDraft(String value) => state = state.copyWith(draft: value);

  Future<void> send([String? text]) async {
    final question = (text ?? state.draft).trim();
    if (question.isEmpty || state.respondendo) return;

    state = state.copyWith(
      draft: '',
      respondendo: true,
      messages: [...state.messages, ChatMessage(text: question, isUser: true)],
    );

    final result = await ref.read(responderPerguntaUseCaseProvider)(question);
    final resposta = result.fold((falha) => falha.message, (texto) => texto);

    state = state.copyWith(
      respondendo: false,
      messages: [...state.messages, ChatMessage(text: resposta, isUser: false, isLocal: true)],
    );
  }
}
