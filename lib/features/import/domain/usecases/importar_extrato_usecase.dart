import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/campo_coluna.dart';
import '../entities/perfil_banco.dart';
import '../entities/preview_arquivo.dart';
import '../entities/transacao_importada.dart';
import '../repositories/import_repository.dart';

/// Orquestra os passos 2-7 do fluxo de importação (ver
/// `.claude/docs/IMPORT_FLOW.md`) via dependências injetadas — nunca
/// hardcoded para um banco específico.
class ImportarExtratoUseCase {
  ImportarExtratoUseCase(this._repository);

  final ImportRepository _repository;

  Future<Either<Failure, PreviewArquivo>> analisar(Uint8List bytes) {
    return _repository.analisarArquivo(bytes);
  }

  Future<Either<Failure, List<TransacaoImportada>>> importar({
    required Uint8List bytes,
    required PerfilBanco perfil,
  }) {
    if (perfil.mapeamentoColunas.values.where((c) => c == CampoColuna.data).length != 1 ||
        perfil.mapeamentoColunas.values.where((c) => c == CampoColuna.valor).length != 1) {
      return Future.value(
        const Left(ValidationFailure('Mapeie exatamente uma coluna de Data e uma de Valor antes de importar.')),
      );
    }
    return _repository.importar(bytes: bytes, perfil: perfil);
  }
}
