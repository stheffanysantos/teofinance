import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/contas/data/datasources/conta_local_datasource.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/repositories/conta_repository.dart';

class ContaRepositoryImpl implements ContaRepository {
  ContaRepositoryImpl(this._local);

  final ContaLocalDataSource _local;

  @override
  Stream<List<ContaAPagar>> observarTodas() => _local.observarTodas();

  @override
  Future<Either<Failure, ContaAPagar>> criar({
    required String descricao,
    required double valor,
    required DateTime vencimento,
    String categoria = '',
    RecorrenciaConta recorrencia = RecorrenciaConta.nenhuma,
    int diasAntesLembrete = 1,
    int? diaBase,
  }) async {
    try {
      return Right(await _local.criar(
        descricao: descricao,
        valor: valor,
        vencimento: vencimento,
        categoria: categoria,
        recorrencia: recorrencia,
        diasAntesLembrete: diasAntesLembrete,
        diaBase: diaBase,
      ));
    } catch (_) {
      return const Left(CacheFailure('Não foi possível salvar a conta.'));
    }
  }

  @override
  Future<Either<Failure, ContaAPagar>> atualizar(ContaAPagar conta) async {
    try {
      final atual = await _local.obter(conta.id);
      if (atual == null) return const Left(CacheFailure('Conta não encontrada.'));
      if (atual.paga) return const Left(ValidationFailure('Uma conta paga não pode ser editada.'));

      await _local.atualizar(conta);
      return Right((await _local.obter(conta.id))!);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível salvar a conta.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async {
    try {
      await _local.excluir(id);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível excluir a conta.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> marcarComoPaga({
    required String id,
    required double valorPago,
    required DateTime dataPagamento,
    String? transacaoId,
  }) async {
    try {
      final atual = await _local.obter(id);
      if (atual == null) return const Left(CacheFailure('Conta não encontrada.'));
      if (atual.paga) return const Left(ValidationFailure('Esta conta já foi paga.'));

      await _local.marcarComoPaga(
        id: id,
        valorPago: valorPago,
        dataPagamento: dataPagamento,
        transacaoId: transacaoId,
      );
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Não foi possível registrar o pagamento.'));
    }
  }

  @override
  Future<List<ContaAPagar>> listarPendentesDeSincronizacao() => _local.listarPendentes();

  @override
  Future<List<ContaAPagar>> listarPendentesDeExclusao() => _local.listarPendentesDeExclusao();

  @override
  Future<void> confirmarSincronizacao({required String id, required String remoteId}) {
    return _local.confirmarSincronizacao(id: id, remoteId: remoteId);
  }

  @override
  Future<void> confirmarExclusao(String id) => _local.confirmarExclusao(id);

  @override
  Future<void> aplicarRemoto(ContaAPagar conta) => _local.aplicarRemoto(conta);
}
