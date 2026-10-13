import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lição "Juros compostos" (Unidade 2, questão 2 de 5) — ver Quiz.dc.html.
///
/// TODO(fase-3): generalizar para múltiplas lições/perguntas quando o
/// conteúdo da trilha deixar de ser estático (`.claude/agents/gamification-engineer.md`).
class QuizOption {
  const QuizOption({required this.letter, required this.text});

  final String letter;
  final String text;
}

const kQuizQuestion = 'O que é o CDI?';
const kQuizOptions = [
  QuizOption(letter: 'A', text: 'Um imposto cobrado sobre investimentos de renda fixa'),
  QuizOption(letter: 'B', text: 'Taxa de referência baseada nos empréstimos entre bancos'),
  QuizOption(letter: 'C', text: 'Um tipo de ação negociada na bolsa'),
  QuizOption(letter: 'D', text: 'Um fundo garantido pelo governo'),
];
const kQuizCorrectIndex = 1;
const kQuizCorrectExplanation =
    'O CDI acompanha a taxa dos empréstimos entre bancos e serve de base para o rendimento de CDBs e fundos.';
const kQuizWrongExplanation =
    'O CDI é a taxa de referência dos empréstimos entre bancos, usada como base para o rendimento de '
    'CDBs e fundos. Não é imposto, ação nem fundo.';

class QuizState {
  const QuizState({this.selectedIndex, this.checked = false});

  final int? selectedIndex;
  final bool checked;

  bool get isCorrect => checked && selectedIndex == kQuizCorrectIndex;
  bool get canCheck => selectedIndex != null;

  QuizState copyWith({int? selectedIndex, bool? checked, bool clearSelection = false}) {
    return QuizState(
      selectedIndex: clearSelection ? null : (selectedIndex ?? this.selectedIndex),
      checked: checked ?? this.checked,
    );
  }
}

final quizProvider = NotifierProvider.autoDispose<QuizNotifier, QuizState>(QuizNotifier.new);

class QuizNotifier extends AutoDisposeNotifier<QuizState> {
  @override
  QuizState build() => const QuizState();

  void select(int index) {
    if (state.checked) return;
    state = state.copyWith(selectedIndex: index);
  }

  /// Verifica a resposta, ou avança/reinicia se já verificada.
  void primaryAction() {
    if (!state.checked) {
      if (!state.canCheck) return;
      state = state.copyWith(checked: true);
    } else {
      state = const QuizState();
    }
  }
}
