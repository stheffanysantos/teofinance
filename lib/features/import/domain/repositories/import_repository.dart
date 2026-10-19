import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/extrato_importado.dart';
import '../entities/formato_extrato.dart';
import '../entities/perfil_banco.dart';
import '../entities/preview_arquivo.dart';
import '../entities/transacao_importada.dart';

/// Parsing de arquivo — nunca toca Firestore/rede (ver
/// `.claude/rules/security.md`, seção "Importação de extrato").
abstract class ImportRepository {
  /// Reconhece o formato pelo conteúdo do arquivo.
  FormatoExtrato detectarFormato(Uint8List bytes);

  /// OFX já descreve cada campo, então não passa por mapeamento de colunas nem
  /// por Perfil de Banco. Falha com `ValidationFailure` apontando a transação
  /// inválida, em vez de pular ou corrigir um valor em silêncio.
  Future<Either<Failure, ExtratoImportado>> importarOfx(Uint8List bytes);

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
