import 'transacao_importada.dart';

/// Extrato já interpretado, em memória (ainda não persistido).
class ExtratoImportado {
  const ExtratoImportado({required this.transacoes, this.instituicao});

  final List<TransacaoImportada> transacoes;

  /// Nome do banco, quando o arquivo informa (OFX traz `<ORG>`).
  final String? instituicao;
}
