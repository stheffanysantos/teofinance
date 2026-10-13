import 'perfil_banco.dart';

/// Resultado da análise inicial de um arquivo (passo 2-3 do fluxo): o que
/// foi detectado automaticamente, mais uma amostra de linhas para o
/// usuário conferir antes de mapear ou confirmar um perfil sugerido.
class PreviewArquivo {
  const PreviewArquivo({
    required this.cabecalho,
    required this.linhasAmostra,
    required this.delimitador,
    required this.codificacaoLatin1,
    required this.temCabecalho,
    this.perfilCompativel,
  });

  final List<String> cabecalho;
  final List<List<String>> linhasAmostra;
  final String delimitador;
  final bool codificacaoLatin1;
  final bool temCabecalho;

  /// Perfil salvo compatível com este arquivo, se algum `BankProfileMatcher`
  /// encontrou um (mesmo número de colunas). `null` = banco novo, ou
  /// nenhum perfil salvo bate — usuário precisa mapear manualmente.
  final PerfilBanco? perfilCompativel;

  int get numeroColunas => cabecalho.length;
}
