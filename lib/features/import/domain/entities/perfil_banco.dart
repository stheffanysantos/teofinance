import '../../../../core/sync/sync_status.dart';
import 'campo_coluna.dart';

/// Mapeamento de colunas salvo pelo usuário na primeira importação de um
/// banco — reaplicado automaticamente em importações futuras do mesmo
/// layout (ver `.claude/docs/IMPORT_FLOW.md`).
///
/// Isto é o que torna o parser agnóstico de banco: nada no código conhece
/// "Nubank" ou "Banco do Brasil" — só este objeto, que o próprio usuário
/// (ou um modelo de partida sugerido) preenche.
class PerfilBanco {
  const PerfilBanco({
    required this.id,
    required this.nomeBanco,
    required this.delimitador,
    required this.codificacaoLatin1,
    required this.temCabecalho,
    required this.formatoData,
    required this.separadorDecimalVirgula,
    required this.mapeamentoColunas,
    required this.assinaturaCabecalho,
    this.remoteId,
    this.syncStatus = SyncStatus.pendingCreate,
  });

  final String id;
  final String nomeBanco;

  /// `,` `;` ou `\t`.
  final String delimitador;

  /// `false` = UTF-8 (padrão), `true` = Latin-1/ISO-8859-1.
  final bool codificacaoLatin1;

  final bool temCabecalho;

  /// Um de `kFormatosDataSuportados`.
  final String formatoData;

  /// `true` = `1.234,56` (padrão BR), `false` = `1234.56`.
  final bool separadorDecimalVirgula;

  /// Índice da coluna (0-based) → o que ela representa.
  final Map<int, CampoColuna> mapeamentoColunas;

  /// Cabeçalho do arquivo original usado para reconhecer automaticamente
  /// este perfil numa próxima importação (ver `BankProfileMatcher`).
  final List<String> assinaturaCabecalho;

  final String? remoteId;
  final SyncStatus syncStatus;

  int get numeroColunasEsperado => assinaturaCabecalho.length;

  PerfilBanco copyWith({
    String? nomeBanco,
    Map<int, CampoColuna>? mapeamentoColunas,
    String? remoteId,
    SyncStatus? syncStatus,
  }) {
    return PerfilBanco(
      id: id,
      nomeBanco: nomeBanco ?? this.nomeBanco,
      delimitador: delimitador,
      codificacaoLatin1: codificacaoLatin1,
      temCabecalho: temCabecalho,
      formatoData: formatoData,
      separadorDecimalVirgula: separadorDecimalVirgula,
      mapeamentoColunas: mapeamentoColunas ?? this.mapeamentoColunas,
      assinaturaCabecalho: assinaturaCabecalho,
      remoteId: remoteId ?? this.remoteId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

const kFormatosDataSuportados = ['dd/MM/yyyy', 'yyyy-MM-dd', 'MM/dd/yyyy'];
