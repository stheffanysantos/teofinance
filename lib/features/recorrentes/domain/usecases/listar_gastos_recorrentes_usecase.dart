import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/recorrentes/domain/entities/gasto_recorrente.dart';
import 'package:teofinance/features/recorrentes/domain/services/detectar_recorrentes.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';

/// Lê o histórico de transações e devolve as despesas que se repetem.
class ListarGastosRecorrentesUseCase {
  ListarGastosRecorrentesUseCase(this._transacoes, {DateTime Function() agora = DateTime.now}) : _agora = agora;

  final TransacaoRepository _transacoes;
  final DateTime Function() _agora;

  Future<Either<Failure, List<GastoRecorrente>>> call() async {
    try {
      final transacoes = await _transacoes.observarTodas().first;
      return Right(detectarRecorrentes(transacoes, agora: _agora()));
    } catch (_) {
      return const Left(CacheFailure('Não foi possível analisar seus gastos agora.'));
    }
  }
}
