import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/perfil_banco.dart';
import '../entities/preview_arquivo.dart';
import '../entities/transacao_importada.dart';

/// Parsing de arquivo — nunca toca Firestore/rede (ver
/// `.claude/rules/security.md`, seção "Importação de extrato").
abstract class ImportRepository {
  /// Detecta separador/encoding, lê uma amostra e procura um `PerfilBanco`
  /// salvo compatível (passos 2-3 do fluxo).
  Future<Either<Failure, PreviewArquivo>> analisarArquivo(Uint8List bytes);

  /// Aplica [perfil] ao arquivo inteiro. Falha explicitamente
  /// (`ValidationFailure`) se o número de colunas do arquivo não bater com
  /// o esperado pelo perfil — nunca mapeia colunas erradas silenciosamente.
  Future<Either<Failure, List<TransacaoImportada>>> importar({
    required Uint8List bytes,
    required PerfilBanco perfil,
  });
}
