import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:teofinance/core/services/edge_ai_motor.dart';

/// Modelo de linguagem local usado pelo assistente: Qwen3 1.7B (int4, `.litertlm`),
/// ≈932 MB. É um degrau acima do Qwen3 0.6B (≈343 MB) que o app usava: entende
/// melhor perguntas sobre o resumo financeiro e ainda cabe em celulares comuns.
/// O app já responde por regras quando o modelo não está instalado. Repositório
/// aberto no Hugging Face (não exige token). Quem baixou o 0.6B precisa baixar
/// este de novo, porque o arquivo muda.
const kModeloLocalId = 'Qwen3-1.7B_dynamic_wi4b32_afp32.litertlm';
const kModeloLocalUrl =
    'https://huggingface.co/litert-community/Qwen3-1.7B/resolve/main/$kModeloLocalId';
const kModeloLocalTamanhoEmMb = 932;

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
  Future<bool> estaInstalado() async {
    await garantirMotorEdgeAi();
    return FlutterEdgeAi.isModelInstalled(kModeloLocalId);
  }

  @override
  Future<void> instalar(void Function(int percentual) aoProgredir) async {
    await garantirMotorEdgeAi();
    await FlutterEdgeAi.installModel(
      modelType: ModelType.qwen3,
      fileType: ModelFileType.litertlm,
    ).fromNetwork(kModeloLocalUrl).withProgress(aoProgredir).install();
  }

  @override
  Future<void> desinstalar() async {
    await garantirMotorEdgeAi();
    await FlutterEdgeAi.uninstallModel(kModeloLocalId);
  }
}
