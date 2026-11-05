import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:teofinance/core/services/edge_ai_motor.dart';

/// Modelo de linguagem local usado pelo assistente: Qwen2.5 1.5B Instruct
/// (q8, `.litertlm`), bem mais leve que o Gemma 4 E2B (≈1,6 GB contra 2,4 GB) e
/// suficiente para perguntas curtas sobre o resumo financeiro. Repositório
/// aberto no Hugging Face (não exige token nem aceite de licença).
const kModeloLocalId = 'Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv4096.litertlm';
const kModeloLocalUrl =
    'https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct/resolve/main/$kModeloLocalId';
const kModeloLocalTamanhoEmMb = 1524;

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
      modelType: ModelType.qwen,
      fileType: ModelFileType.litertlm,
    ).fromNetwork(kModeloLocalUrl).withProgress(aoProgredir).install();
  }

  @override
  Future<void> desinstalar() async {
    await garantirMotorEdgeAi();
    await FlutterEdgeAi.uninstallModel(kModeloLocalId);
  }
}
