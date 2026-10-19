import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/features/ai_assistant/data/services/gerenciador_modelo_indisponivel.dart';
import 'package:teofinance/features/ai_assistant/data/services/inferencia_local_indisponivel.dart';
import 'package:teofinance/features/ai_assistant/data/services/motor_resposta_gemma.dart';
import 'package:teofinance/features/ai_assistant/data/services/motor_resposta_por_regras.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/estado_modelo.dart';
import 'package:teofinance/features/ai_assistant/domain/services/gerenciador_modelo.dart';
import 'package:teofinance/features/ai_assistant/domain/services/inferencia_local.dart';
import 'package:teofinance/features/ai_assistant/domain/services/motor_resposta.dart';
import 'package:teofinance/features/ai_assistant/domain/usecases/responder_pergunta_usecase.dart';
import 'package:teofinance/features/budget/presentation/providers/budget_providers.dart';
import 'package:teofinance/features/meta/presentation/providers/meta_providers.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

/// Inferência do Gemma. Hoje indisponível: a integração com o plugin troca só
/// esta linha (ver `.claude/plans/` e a decisão sobre o runtime em
/// `.claude/memory/decisions.md`).
final inferenciaLocalProvider = Provider<InferenciaLocal>((ref) => const InferenciaLocalIndisponivel());

/// Download/remoção do modelo. Mesma troca: `core/services/` fornecerá a
/// implementação real, fora de `features/ai_assistant/`.
final gerenciadorModeloProvider = Provider<GerenciadorModelo>((ref) => const GerenciadorModeloIndisponivel());

final estadoModeloProvider = StreamProvider<EstadoModelo>((ref) {
  return ref.watch(gerenciadorModeloProvider).observarEstado();
});

final motorRespostaProvider = Provider<MotorResposta>((ref) {
  return MotorRespostaGemma(
    inferencia: ref.watch(inferenciaLocalProvider),
    fallback: const MotorRespostaPorRegras(),
  );
});

final responderPerguntaUseCaseProvider = Provider((ref) {
  return ResponderPerguntaUseCase(
    transacoes: ref.watch(transacaoRepositoryProvider),
    metas: ref.watch(metaRepositoryProvider),
    orcamentos: ref.watch(orcamentoRepositoryProvider),
    motor: ref.watch(motorRespostaProvider),
  );
});
