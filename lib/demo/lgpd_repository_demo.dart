import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/lgpd/data/datasources/lgpd_local_data_source.dart';
import 'package:teofinance/features/lgpd/domain/repositories/lgpd_repository.dart';

/// "Privacidade e dados" na demonstração: só a exportação funciona. Zerar os dados
/// e excluir a conta ficam bloqueados, com um aviso.
class LgpdRepositoryDemo implements LgpdRepository {
  LgpdRepositoryDemo(this._local);

  final LgpdLocalDataSource _local;

  @override
  Future<Either<Failure, String>> exportarDados() async {
    try {
      final dados = await _local.exportarTudo();
      final arquivo = {
        'versao': 1,
        'exportadoEm': DateTime.now().toIso8601String(),
        'conta': {'uid': 'demo', 'email': 'demo@teofinance.app'},
        'dados': dados,
      };
      return Right(const JsonEncoder.withIndent('  ').convert(arquivo));
    } catch (_) {
      return const Left(CacheFailure('Não foi possível reunir os dados da demonstração.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> excluirTodosOsDados({required String senha}) async {
    return const Left(AuthFailure('Indisponível na demonstração: aqui não há conta para excluir.'));
  }

  @override
  Future<Either<Failure, Unit>> zerarDadosFinanceiros() async {
    return const Left(CacheFailure('Indisponível na demonstração: os dados de exemplo não podem ser apagados.'));
  }
}
