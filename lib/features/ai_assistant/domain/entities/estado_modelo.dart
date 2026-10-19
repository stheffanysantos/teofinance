/// Situação do arquivo do modelo de IA neste aparelho.
sealed class EstadoModelo {
  const EstadoModelo();
}

/// O motor de IA ainda não está integrado neste build: o assistente usa só as
/// regras e a interface não mostra nada sobre modelo.
class ModeloIndisponivel extends EstadoModelo {
  const ModeloIndisponivel();
}

class ModeloNaoInstalado extends EstadoModelo {
  const ModeloNaoInstalado({this.tamanhoEmMb});

  final int? tamanhoEmMb;
}

class ModeloBaixando extends EstadoModelo {
  const ModeloBaixando(this.progresso);

  /// De 0.0 a 1.0.
  final double progresso;
}

class ModeloPronto extends EstadoModelo {
  const ModeloPronto();
}

class ModeloComErro extends EstadoModelo {
  const ModeloComErro(this.mensagem);

  final String mensagem;
}
