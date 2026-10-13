import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/nome_feature/domain/entities/nome_entidade.dart';

/// Contrato abstrato — SEM implementação. A implementação decide local x remoto
/// (ver data/repositories/nome_entidade_repository_impl.dart).
abstract class NomeEntidadeRepository {
  Future<Either<Failure, List<NomeEntidade>>> obterTodas();

  Future<Either<Failure, NomeEntidade>> obterPorId(String idRemoto);

  Future<Either<Failure, NomeEntidade>> salvar(NomeEntidade entidade);

  Future<Either<Failure, Unit>> excluir(int idLocal);

  /// Presente apenas se a entidade for sincronizável.
  Future<Either<Failure, Unit>> sincronizarPendentes();
}
