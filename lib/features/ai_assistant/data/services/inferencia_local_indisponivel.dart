import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/ai_assistant/domain/services/inferencia_local.dart';

/// Inferência usada enquanto o motor do Gemma não está integrado neste build:
/// nunca fica pronta, então o assistente responde só por regras. A integração
/// real troca esta classe no provider (`inferenciaLocalProvider`).
class InferenciaLocalIndisponivel implements InferenciaLocal {
  const InferenciaLocalIndisponivel();

  @override
  Future<bool> estaPronta() async => false;

  @override
  Future<Either<Failure, String>> gerar({required String instrucoes, required String mensagem}) async {
    return const Left(CacheFailure('Modelo local indisponível neste build.'));
  }
}
