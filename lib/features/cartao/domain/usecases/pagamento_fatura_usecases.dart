import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/repositories/cartao_repository.dart';
import 'package:teofinance/features/cartao/domain/usecases/salvar_cartao_usecase.dart';
import 'package:teofinance/features/lembrete/domain/repositories/lembrete_repository.dart';

/// Marca a fatura como paga. Não cria transação: as compras já estão nas
/// despesas, então um lançamento novo contaria o gasto duas vezes.
class RegistrarPagamentoFaturaUseCase {
  RegistrarPagamentoFaturaUseCase(this._repository);

  final CartaoRepository _repository;

  Future<Either<Failure, Unit>> call(FaturaPaga pagamento) {
    if (pagamento.valor < 0) {
      return Future.value(const Left(ValidationFailure('O valor pago não pode ser negativo.')));
    }
    return _repository.registrarPagamento(pagamento);
  }
}

class DesfazerPagamentoFaturaUseCase {
  DesfazerPagamentoFaturaUseCase(this._repository);

  final CartaoRepository _repository;

  Future<Either<Failure, Unit>> call({required String cartaoId, required int ano, required int mes}) {
    return _repository.desfazerPagamento(cartaoId: cartaoId, ano: ano, mes: mes);
  }
}

/// Exclui o cartão e os lembretes de fechamento e vencimento dele.
class ExcluirCartaoUseCase {
  ExcluirCartaoUseCase(this._repository, this._lembretes);

  final CartaoRepository _repository;
  final LembreteRepository _lembretes;

  Future<Either<Failure, Unit>> call(String id) async {
    final r = await _repository.excluirCartao(id);
    if (r.isLeft()) return r;
    await _lembretes.excluir(idLembreteFechamento(id));
    await _lembretes.excluir(idLembreteVencimento(id));
    return r;
  }
}
