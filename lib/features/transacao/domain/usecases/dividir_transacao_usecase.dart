import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/transacao_repository.dart';

/// Registra que uma compra foi dividida: [minhaParte] é o que realmente pesa
/// para o usuário, [pessoas] são as outras pessoas da divisão.
class DividirTransacaoUseCase {
  DividirTransacaoUseCase(this._repository);

  final TransacaoRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String id,
    required double valorTotal,
    required double minhaParte,
    required List<String> pessoas,
  }) {
    final nomes = pessoas.map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

    if (nomes.isEmpty) {
      return Future.value(const Left(ValidationFailure('Informe com quem você dividiu.')));
    }
    if (minhaParte <= 0) {
      return Future.value(const Left(ValidationFailure('Sua parte deve ser maior que zero.')));
    }
    if (minhaParte > valorTotal.abs()) {
      return Future.value(const Left(ValidationFailure('Sua parte não pode passar do total.')));
    }
    return _repository.definirDivisao(id: id, minhaParte: minhaParte, divididoCom: nomes);
  }
}
