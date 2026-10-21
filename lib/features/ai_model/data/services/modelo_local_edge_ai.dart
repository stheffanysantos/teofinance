import 'package:flutter_edge_ai/flutter_edge_ai.dart';

/// Modelo de linguagem local usado pelo assistente: Gemma 4 E2B em `.litertlm`.
/// Repositório aberto no Hugging Face (não exige token nem aceite de licença).
/// O Gemma 3 1B, menor, é gated e exigiria um token embutido no app.
const kModeloLocalId = 'gemma-4-E2B-it.litertlm';
const kModeloLocalUrl =
    'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/$kModeloLocalId';
const kModeloLocalTamanhoEmMb = 2468;

/// Operações do plugin de IA local de que o download precisa. Existe para o
/// gerenciador ser testável sem o plugin nativo.
abstract class ModeloLocalEdgeAi {
  Future<bool> estaInstalado();

  /// [aoProgredir] recebe de 0 a 100.
  Future<void> instalar(void Function(int percentual) aoProgredir);

  Future<void> desinstalar();
}

class ModeloLocalEdgeAiPlugin implements ModeloLocalEdgeAi {
  const ModeloLocalEdgeAiPlugin();

  @override
  Future<bool> estaInstalado() =>
      FlutterEdgeAi.isModelInstalled(kModeloLocalId);

  @override
  Future<void> instalar(void Function(int percentual) aoProgredir) async {
    await FlutterEdgeAi.installModel(
      modelType: ModelType.gemma4,
      fileType: ModelFileType.litertlm,
    ).fromNetwork(kModeloLocalUrl).withProgress(aoProgredir).install();
  }

  @override
  Future<void> desinstalar() => FlutterEdgeAi.uninstallModel(kModeloLocalId);
}
