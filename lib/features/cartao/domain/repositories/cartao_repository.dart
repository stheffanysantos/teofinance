import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';

abstract class CartaoRepository {
  Future<Either<Failure, List<Cartao>>> listarCartoes();

  /// Cria (id vazio) ou atualiza.
  Future<Either<Failure, Unit>> salvarCartao(Cartao cartao);

  Future<Either<Failure, Unit>> excluirCartao(String id);

  Future<Either<Failure, List<FaturaPaga>>> listarPagamentos();

  Future<Either<Failure, Unit>> registrarPagamento(FaturaPaga pagamento);

  Future<Either<Failure, Unit>> desfazerPagamento({required String cartaoId, required int ano, required int mes});

  // Usados só por `features/sync/` — ver `.claude/rules/architecture.md`.

  Future<List<Cartao>> cartoesPendentesDeSincronizacao();
  Future<List<String>> cartoesPendentesDeExclusao();
  Future<void> confirmarCartao(String id);
  Future<void> confirmarExclusaoCartao(String id);
  Future<void> aplicarCartaoRemoto(Cartao cartao);
  Future<void> removerCartoesAusentes(Set<String> idsRemotos);

  Future<List<FaturaPaga>> pagamentosPendentesDeSincronizacao();
  Future<List<String>> pagamentosPendentesDeExclusao();
  Future<void> confirmarPagamento(String id);
  Future<void> confirmarExclusaoPagamento(String id);
  Future<void> aplicarPagamentoRemoto(FaturaPaga pagamento);
  Future<void> removerPagamentosAusentes(Set<String> idsRemotos);
}
