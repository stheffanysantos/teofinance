import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/cartao/data/datasources/cartao_local_data_source.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/repositories/cartao_repository.dart';

class CartaoRepositoryImpl implements CartaoRepository {
  CartaoRepositoryImpl(this._local);

  final CartaoLocalDataSource _local;

  Future<Either<Failure, T>> _tentar<T>(Future<T> Function() acao, String mensagem) async {
    try {
      return Right(await acao());
    } catch (e) {
      debugPrint('CartaoRepositoryImpl falhou: ${e.runtimeType}');
      return Left(CacheFailure(mensagem));
    }
  }

  @override
  Future<Either<Failure, List<Cartao>>> listarCartoes() =>
      _tentar(_local.listarCartoes, 'Não foi possível carregar os cartões.');

  @override
  Future<Either<Failure, Unit>> salvarCartao(Cartao cartao) =>
      _tentar(() async {
        await _local.salvarCartao(cartao);
        return unit;
      }, 'Não foi possível salvar o cartão.');

  @override
  Future<Either<Failure, Unit>> excluirCartao(String id) =>
      _tentar(() async {
        await _local.excluirCartao(id);
        return unit;
      }, 'Não foi possível excluir o cartão.');

  @override
  Future<Either<Failure, List<FaturaPaga>>> listarPagamentos() =>
      _tentar(_local.listarPagamentos, 'Não foi possível carregar os pagamentos.');

  @override
  Future<Either<Failure, Unit>> registrarPagamento(FaturaPaga pagamento) =>
      _tentar(() async {
        await _local.registrarPagamento(pagamento);
        return unit;
      }, 'Não foi possível registrar o pagamento.');

  @override
  Future<Either<Failure, Unit>> desfazerPagamento({required String cartaoId, required int ano, required int mes}) =>
      _tentar(() async {
        await _local.desfazerPagamento(idFatura(cartaoId, ano, mes));
        return unit;
      }, 'Não foi possível desfazer o pagamento.');

  @override
  Future<List<Cartao>> cartoesPendentesDeSincronizacao() => _local.cartoesPendentes();

  @override
  Future<List<String>> cartoesPendentesDeExclusao() => _local.cartoesPendentesDeExclusao();

  @override
  Future<void> confirmarCartao(String id) => _local.confirmarCartao(id);

  @override
  Future<void> confirmarExclusaoCartao(String id) => _local.confirmarExclusaoCartao(id);

  @override
  Future<void> aplicarCartaoRemoto(Cartao cartao) => _local.aplicarCartaoRemoto(cartao);

  @override
  Future<void> removerCartoesAusentes(Set<String> idsRemotos) => _local.removerCartoesAusentes(idsRemotos);

  @override
  Future<List<FaturaPaga>> pagamentosPendentesDeSincronizacao() => _local.pagamentosPendentes();

  @override
  Future<List<String>> pagamentosPendentesDeExclusao() => _local.pagamentosPendentesDeExclusao();

  @override
  Future<void> confirmarPagamento(String id) => _local.confirmarPagamento(id);

  @override
  Future<void> confirmarExclusaoPagamento(String id) => _local.confirmarExclusaoPagamento(id);

  @override
  Future<void> aplicarPagamentoRemoto(FaturaPaga pagamento) => _local.aplicarPagamentoRemoto(pagamento);

  @override
  Future<void> removerPagamentosAusentes(Set<String> idsRemotos) => _local.removerPagamentosAusentes(idsRemotos);
}
