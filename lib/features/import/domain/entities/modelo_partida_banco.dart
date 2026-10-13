import 'campo_coluna.dart';

/// Sugestão de mapeamento para acelerar a primeira importação de um banco
/// conhecido — **não** é um caso especial no parser: é só um `PerfilBanco`
/// pré-preenchido que o usuário confere e ajusta contra o arquivo real que
/// baixou, antes de salvar como perfil próprio (ver
/// `.claude/docs/IMPORT_FLOW.md`). Qualquer banco fora desta lista segue o
/// mesmo fluxo de mapeamento manual — o app funciona para qualquer um.
class ModeloPartidaBanco {
  const ModeloPartidaBanco({
    required this.nomeBanco,
    required this.delimitador,
    required this.codificacaoLatin1,
    required this.temCabecalho,
    required this.formatoData,
    required this.separadorDecimalVirgula,
    required this.mapeamentoColunas,
    required this.cabecalhoEsperado,
  });

  final String nomeBanco;
  final String delimitador;
  final bool codificacaoLatin1;
  final bool temCabecalho;
  final String formatoData;
  final bool separadorDecimalVirgula;
  final Map<int, CampoColuna> mapeamentoColunas;

  /// Cabeçalho esperado — usado só para mostrar ao usuário como referência,
  /// nunca para "adivinhar" automaticamente que o arquivo é deste banco.
  final List<String> cabecalhoEsperado;
}

/// Baseados no layout de export mais comum relatado por usuários destes
/// bancos — **confirme contra o seu próprio arquivo** na tela de mapeamento
/// antes de salvar; o banco pode ter mudado o layout desde então.
const kModelosPartidaBanco = [
  ModeloPartidaBanco(
    nomeBanco: 'Nubank (conta)',
    delimitador: ',',
    codificacaoLatin1: false,
    temCabecalho: true,
    formatoData: 'yyyy-MM-dd',
    separadorDecimalVirgula: false,
    mapeamentoColunas: {
      0: CampoColuna.data,
      1: CampoColuna.valor,
      2: CampoColuna.ignorar,
      3: CampoColuna.descricao,
    },
    cabecalhoEsperado: ['Data', 'Valor', 'Identificador', 'Descrição'],
  ),
  ModeloPartidaBanco(
    nomeBanco: 'Nubank (cartão)',
    delimitador: ',',
    codificacaoLatin1: false,
    temCabecalho: true,
    formatoData: 'yyyy-MM-dd',
    separadorDecimalVirgula: false,
    mapeamentoColunas: {
      0: CampoColuna.data,
      1: CampoColuna.descricao,
      2: CampoColuna.valor,
    },
    cabecalhoEsperado: ['date', 'title', 'amount'],
  ),
  ModeloPartidaBanco(
    nomeBanco: 'Banco do Brasil',
    delimitador: ';',
    codificacaoLatin1: true,
    temCabecalho: true,
    formatoData: 'dd/MM/yyyy',
    separadorDecimalVirgula: true,
    mapeamentoColunas: {
      0: CampoColuna.data,
      1: CampoColuna.ignorar,
      2: CampoColuna.descricao,
      3: CampoColuna.ignorar,
      4: CampoColuna.ignorar,
      5: CampoColuna.valor,
    },
    cabecalhoEsperado: [
      'Data',
      'Dependência Origem',
      'Histórico',
      'Data do Balancete',
      'Número do Documento',
      'Valor',
    ],
  ),
];
