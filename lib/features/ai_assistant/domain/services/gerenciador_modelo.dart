import 'package:teofinance/features/ai_assistant/domain/entities/estado_modelo.dart';

/// Instala e remove o arquivo do modelo (baixado sob demanda, nunca embutido
/// no instalador). É a única parte do assistente que pode usar rede, e só para
/// trazer o modelo — a implementação mora fora de `features/ai_assistant/`
/// (`core/services/`) para a inferência seguir livre de qualquer rede.
abstract class GerenciadorModelo {
  /// Emite o estado atual ao assinar e a cada mudança depois.
  Stream<EstadoModelo> observarEstado();

  Future<void> baixar();

  Future<void> remover();
}
