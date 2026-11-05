import 'transacao_importada.dart';

/// Extrato já interpretado, em memória (ainda não persistido).
class ExtratoImportado {
  const ExtratoImportado({
    required this.transacoes,
    this.instituicao,
    this.saldoFinal,
    this.ehCartao = false,
  });

  final List<TransacaoImportada> transacoes;

  /// Nome do banco, quando o arquivo informa (OFX traz `<ORG>`).
  final String? instituicao;

  /// Saldo final da conta informado pelo banco (`LEDGERBAL`). Nulo no CSV e
  /// quando o arquivo não traz. Em fatura de cartão é o valor da fatura, não o
  /// saldo de uma conta, por isso só vale quando [ehCartao] é falso.
  final double? saldoFinal;

  /// O arquivo é uma fatura de cartão (`CCSTMTRS`) e não uma conta corrente.
  final bool ehCartao;
}
