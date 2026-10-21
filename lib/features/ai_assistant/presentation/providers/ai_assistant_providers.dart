import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/features/ai_assistant/data/services/inferencia_local_edge_ai.dart';
import 'package:teofinance/features/ai_assistant/data/services/motor_resposta_gemma.dart';
import 'package:teofinance/features/ai_assistant/data/services/motor_resposta_por_regras.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/estado_modelo.dart';
import 'package:teofinance/features/ai_assistant/domain/services/gerenciador_modelo.dart';
import 'package:teofinance/features/ai_assistant/domain/services/inferencia_local.dart';
import 'package:teofinance/features/ai_assistant/domain/services/motor_resposta.dart';
import 'package:teofinance/features/ai_assistant/domain/usecases/responder_pergunta_usecase.dart';
import 'package:teofinance/features/ai_model/data/services/gerenciador_modelo_edge_ai.dart';
import 'package:teofinance/features/ai_model/data/services/modelo_local_edge_ai.dart';
import 'package:teofinance/features/budget/presentation/providers/budget_providers.dart';
import 'package:teofinance/features/meta/presentation/providers/meta_providers.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

/// Inferência do Gemma no aparelho (LiteRT-LM). Sem o modelo baixado, `estaPronta`
/// é falso e o assistente responde pelas regras.
final inferenciaLocalProvider = Provider<InferenciaLocal>(
  (ref) => InferenciaLocalEdgeAi.plugin(modeloId: kModeloLocalId),
);

/// Download/remoção do modelo, em `features/ai_model/` (fora desta feature, para
/// a inferência seguir sem rede).
final gerenciadorModeloProvider = Provider<GerenciadorModelo>(
  (ref) => GerenciadorModeloEdgeAi(const ModeloLocalEdgeAiPlugin()),
);

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
