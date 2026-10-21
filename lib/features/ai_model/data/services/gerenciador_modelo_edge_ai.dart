import 'dart:async';

import 'package:teofinance/features/ai_assistant/domain/entities/estado_modelo.dart';
import 'package:teofinance/features/ai_assistant/domain/services/gerenciador_modelo.dart';
import 'package:teofinance/features/ai_model/data/services/modelo_local_edge_ai.dart';

/// Baixa, confere e remove o arquivo do modelo local. É a única parte do
/// assistente com acesso à rede, e só para trazer o modelo; fica fora de
/// `features/ai_assistant/` para a inferência continuar auditável pelo teste de
/// privacidade (decisão 0006).
class GerenciadorModeloEdgeAi implements GerenciadorModelo {
  GerenciadorModeloEdgeAi(this._modelo) {
    _verificar();
  }

  final ModeloLocalEdgeAi _modelo;
  final _controller = StreamController<EstadoModelo>.broadcast();
  EstadoModelo _estado = const ModeloNaoInstalado(
    tamanhoEmMb: kModeloLocalTamanhoEmMb,
  );
  bool _baixando = false;

  void _emitir(EstadoModelo estado) {
    _estado = estado;
    if (!_controller.isClosed) _controller.add(estado);
  }

  Future<void> _verificar() async {
    try {
      if (await _modelo.estaInstalado()) _emitir(const ModeloPronto());
    } catch (_) {
      // Sem confirmação, o estado inicial (não instalado) já oferece baixar.
    }
  }

  @override
  Stream<EstadoModelo> observarEstado() {
    // Assina o fluxo no mesmo instante do `listen`: um `async*` deixaria
    // escapar mudanças de estado emitidas entre o `listen` e a primeira
    // iteração do gerador.
    late final StreamController<EstadoModelo> saida;
    StreamSubscription<EstadoModelo>? assinatura;
    saida = StreamController<EstadoModelo>(
      onListen: () {
        saida.add(_estado);
        assinatura = _controller.stream.listen(saida.add);
      },
      onCancel: () => assinatura?.cancel(),
    );
    return saida.stream;
  }

  @override
  Future<void> baixar() async {
    if (_baixando || _estado is ModeloPronto) return;
    _baixando = true;
    _emitir(const ModeloBaixando(0));
    try {
      await _modelo.instalar(
        (p) => _emitir(ModeloBaixando(p.clamp(0, 100) / 100)),
      );
      _emitir(const ModeloPronto());
    } catch (_) {
      _emitir(
        const ModeloComErro(
          'verifique a conexão e o espaço livre no aparelho.',
        ),
      );
    } finally {
      _baixando = false;
    }
  }

  @override
  Future<void> remover() async {
    try {
      await _modelo.desinstalar();
    } catch (_) {
      // Já não estava instalado: o resultado desejado é o mesmo.
    }
    _emitir(const ModeloNaoInstalado(tamanhoEmMb: kModeloLocalTamanhoEmMb));
  }
}
