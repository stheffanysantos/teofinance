import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/meta.dart';

abstract class MetaRepository {
  Stream<List<Meta>> observarTodas();

  Future<Either<Failure, Meta>> criar({
    required String nome,
    required double valorAlvo,
    required DateTime prazo,
    double valorAtual = 0,
  });

  /// Soma [valor] ao valor atual guardado (aporte) — nunca substitui.
  Future<Either<Failure, Unit>> aportar({required String id, required double valor});

  Future<Either<Failure, Unit>> excluir(String id);

  /// Usado só por `features/sync/`.
  Future<List<Meta>> listarPendentesDeSincronizacao();

  Future<void> confirmarSincronizacao({required String id, required String remoteId});

  Future<void> aplicarRemoto(Meta meta);
}
