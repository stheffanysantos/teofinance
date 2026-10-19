import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';

/// Gera texto com um modelo de linguagem rodando no aparelho (Gemma).
///
/// Implementações nunca fazem chamada de rede: o download do modelo é outra
/// responsabilidade (`GerenciadorModelo`), separada de propósito para que a
/// inferência continue auditável pelo teste de privacidade
/// (`.claude/rules/architecture.md`).
abstract class InferenciaLocal {
  /// `true` quando o modelo está instalado e carregável. Falso nunca é erro:
  /// o assistente simplesmente responde pelas regras.
  Future<bool> estaPronta();

  Future<Either<Failure, String>> gerar({
    required String instrucoes,
    required String mensagem,
  });
}
