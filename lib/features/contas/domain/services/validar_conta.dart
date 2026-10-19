import 'package:teofinance/core/errors/failure.dart';

/// Maior antecedência de lembrete aceita, em dias.
const kMaxDiasAntesLembrete = 30;

/// Regras de negócio de uma conta, aplicadas sempre no caso de uso (a tela só
/// dá feedback imediato). Devolve a falha, ou nulo se está tudo certo.
Failure? validarConta({
  required String descricao,
  required double valor,
  required int diasAntesLembrete,
}) {
  if (descricao.trim().isEmpty) {
    return const ValidationFailure('Dê um nome à conta.');
  }
  if (valor.isNaN || valor.isInfinite || valor <= 0) {
    return const ValidationFailure('O valor precisa ser maior que zero.');
  }
  if (diasAntesLembrete < 0 || diasAntesLembrete > kMaxDiasAntesLembrete) {
    return const ValidationFailure('O lembrete pode ser de 0 a $kMaxDiasAntesLembrete dias antes.');
  }
  return null;
}
