import '../../domain/entities/perfil_banco.dart';

/// Decide se um `PerfilBanco` salvo ainda é compatível com o arquivo atual
/// — nunca aplica um perfil cujo número de colunas não bate (ver
/// `.claude/rules/architecture.md`, regra de importação).
class BankProfileMatcher {
  /// Procura, em [candidatos], o primeiro perfil cuja assinatura de
  /// cabeçalho é idêntica (célula a célula, normalizada) à do arquivo
  /// atual. `null` se nenhum bater — o usuário mapeia manualmente.
  PerfilBanco? encontrarCompativel(List<PerfilBanco> candidatos, List<String> cabecalhoArquivo) {
    final assinaturaAtual = _normalizar(cabecalhoArquivo);
    for (final perfil in candidatos) {
      if (_normalizar(perfil.assinaturaCabecalho).join('|') == assinaturaAtual.join('|')) {
        return perfil;
      }
    }
    return null;
  }

  /// Verdadeiro só se o número de colunas do arquivo atual bater com o
  /// esperado pelo perfil — a checagem de incompatibilidade do passo 3.
  bool compativel(PerfilBanco perfil, int numeroColunasArquivo) {
    return perfil.numeroColunasEsperado == numeroColunasArquivo;
  }

  List<String> _normalizar(List<String> cabecalho) {
    return cabecalho.map((c) => c.trim().toLowerCase()).toList();
  }
}
