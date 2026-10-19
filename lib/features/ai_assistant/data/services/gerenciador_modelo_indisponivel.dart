import 'package:teofinance/features/ai_assistant/domain/entities/estado_modelo.dart';
import 'package:teofinance/features/ai_assistant/domain/services/gerenciador_modelo.dart';

/// Gerenciador usado enquanto o download do modelo não está integrado: o estado
/// é sempre "indisponível" e a interface não oferece baixar nada.
class GerenciadorModeloIndisponivel implements GerenciadorModelo {
  const GerenciadorModeloIndisponivel();

  @override
  Stream<EstadoModelo> observarEstado() => Stream.value(const ModeloIndisponivel());

  @override
  Future<void> baixar() async {}

  @override
  Future<void> remover() async {}
}
