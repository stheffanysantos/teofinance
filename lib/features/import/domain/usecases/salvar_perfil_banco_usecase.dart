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
    return _repository.salvar(perfil);
  }
}
