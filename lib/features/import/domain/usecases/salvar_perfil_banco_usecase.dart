import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/campo_coluna.dart';
import '../entities/perfil_banco.dart';
import '../repositories/perfil_banco_repository.dart';

class SalvarPerfilBancoUseCase {
  SalvarPerfilBancoUseCase(this._repository);

  final PerfilBancoRepository _repository;

  Future<Either<Failure, PerfilBanco>> call(PerfilBanco perfil) {
    if (perfil.nomeBanco.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Dê um nome ao perfil (ex.: o nome do banco).')));
    }
    final temData = perfil.mapeamentoColunas.values.contains(CampoColuna.data);
    final temValor = perfil.mapeamentoColunas.values.contains(CampoColuna.valor);
    if (!temData || !temValor) {
      return Future.value(
        const Left(ValidationFailure('Mapeie ao menos as colunas de Data e Valor antes de salvar.')),
      );
    }
    final colunas = perfil.numeroColunasEsperado;
    if (perfil.mapeamentoColunas.keys.any((indice) => indice < 0 || indice >= colunas)) {
      return Future.value(
        Left(
          ValidationFailure(
            'O mapeamento usa uma coluna que o arquivo não tem (o arquivo tem $colunas colunas). '
            'Remapeie manualmente em vez de usar um modelo de outro banco.',
          ),
        ),
      );
    }
    return _repository.salvar(perfil);
  }
}
