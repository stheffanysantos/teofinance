/// Um parcelamento de uma compra de cartão de crédito.
/// Quando um usuário parcelada um compra, cria 1 Parcelamento (a "mãe")
/// e N transações-filhas (uma por parcela) referenciadas via `parcelamentoId`.
class Parcelamento {
  const Parcelamento({
    required this.id,
    required this.transacaoOriginalId,
    required this.totalOriginal,
    required this.numeroParcelas,
    required this.dataPrimeiraParc,
    required this.updatedAt,
    this.remoteId,
  });

  final String id;
  final String? remoteId;
  final String transacaoOriginalId;
  final double totalOriginal;
  final int numeroParcelas;
  final DateTime dataPrimeiraParc;
  final DateTime updatedAt;

  double get valorParcela => totalOriginal / numeroParcelas;
}
