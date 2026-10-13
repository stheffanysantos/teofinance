import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/core/status/sync_status.dart';
import 'package:teofinance/features/nome_feature/data/datasources/nome_entidade_local_data_source.dart';
import 'package:teofinance/features/nome_feature/data/datasources/nome_entidade_remote_data_source.dart';
import 'package:teofinance/features/nome_feature/data/models/nome_entidade_model.dart';
import 'package:teofinance/features/nome_feature/domain/entities/nome_entidade.dart';
import 'package:teofinance/features/nome_feature/domain/repositories/nome_entidade_repository.dart';

/// ÚNICO lugar que decide local x remoto para esta entidade.
/// Firestore é a fonte de verdade (ver .claude/memory/decisions.md, decisão 0001);
/// o cache local (drift) é usado para leitura offline e fila de escrita pendente.
class NomeEntidadeRepositoryImpl implements NomeEntidadeRepository {
  NomeEntidadeRepositoryImpl({required this.remote, required this.local});

  final NomeEntidadeRemoteDataSource remote;
  final NomeEntidadeLocalDataSource local;

  @override
  Future<Either<Failure, List<NomeEntidade>>> obterTodas() async {
    try {
      final remotas = await remote.obterTodas();
      // Em produção: casar com o cache local e atualizar linhas `synced`.
      return Right(remotas.map((m) => m.toEntity()).toList());
    } catch (_) {
      try {
        final locais = await local.obterTodas();
        return Right(locais
            .map((row) => NomeEntidadeModel(
                  idRemoto: row.idRemoto,
                  descricao: row.descricao,
                  valor: row.valor,
                  data: row.data,
                ).toEntity(idLocal: row.idLocal, syncStatus: row.syncStatus))
            .toList());
      } catch (e) {
        return Left(CacheFailure('Falha ao ler cache local: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, NomeEntidade>> obterPorId(String idRemoto) async {
    try {
      final model = await remote.obterPorId(idRemoto);
      return Right(model.toEntity());
    } catch (e) {
      return Left(NetworkFailure('Falha ao consultar $idRemoto: $e'));
    }
  }

  @override
  Future<Either<Failure, NomeEntidade>> salvar(NomeEntidade entidade) async {
    // Grava local primeiro (pendingCreate/pendingUpdate) — sync/ envia depois.
    try {
      final model = NomeEntidadeModel.fromEntity(entidade);
      final idLocal = await local.inserirOuAtualizar(model.toCompanion(entidade));
      return Right(entidade.copyWith(idLocal: idLocal));
    } catch (e) {
      return Left(CacheFailure('Falha ao salvar localmente: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> excluir(int idLocal) async {
    try {
      await local.excluir(idLocal);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Falha ao excluir localmente: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sincronizarPendentes() async {
    final pendentes = await local.obterPendentes();
    final erros = <String>[];
    for (final row in pendentes) {
      try {
        final model = NomeEntidadeModel(
          idRemoto: row.idRemoto,
          descricao: row.descricao,
          valor: row.valor,
          data: row.data,
        );
        final idRemoto = await remote.salvar(model);
        await local.marcarSincronizado(row.idLocal, idRemoto);
      } catch (e) {
        // Falha em um item NUNCA interrompe os demais.
        erros.add('idLocal=${row.idLocal}: $e');
      }
    }
    if (erros.isNotEmpty) {
      return Left(SyncFailure('Falha parcial ao sincronizar: ${erros.join('; ')}'));
    }
    return const Right(unit);
  }
}
