import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/features/ai_assistant/data/services/motor_resposta_por_regras.dart';
import 'package:teofinance/features/ai_assistant/domain/services/motor_resposta.dart';
import 'package:teofinance/features/ai_assistant/domain/usecases/responder_pergunta_usecase.dart';
import 'package:teofinance/features/budget/presentation/providers/budget_providers.dart';
import 'package:teofinance/features/meta/presentation/providers/meta_providers.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

final motorRespostaProvider = Provider<MotorResposta>((ref) => const MotorRespostaPorRegras());

final responderPerguntaUseCaseProvider = Provider((ref) {
  return ResponderPerguntaUseCase(
    transacoes: ref.watch(transacaoRepositoryProvider),
    metas: ref.watch(metaRepositoryProvider),
    orcamentos: ref.watch(orcamentoRepositoryProvider),
    motor: ref.watch(motorRespostaProvider),
  );
});
