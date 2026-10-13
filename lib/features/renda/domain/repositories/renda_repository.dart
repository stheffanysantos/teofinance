import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/renda.dart';

abstract class RendaRepository {
  Stream<List<Renda>> observarTodas();

  Future<Either<Failure, Renda>> criar({
    required String descricao,
    required double valor,
    required TipoRenda tipo,
    required DateTime dataRecebimento,
    RecorrenciaRenda? recorrencia,
  });

  Future<Either<Failure, Unit>> definirAtiva({required String id, required bool ativa});

  Future<Either<Failure, Unit>> excluir(String id);

  /// Usado só por `features/sync/`.
  Future<List<Renda>> listarPendentesDeSincronizacao();

  Future<void> confirmarSincronizacao({required String id, required String remoteId});

  Future<void> aplicarRemoto(Renda renda);
}
