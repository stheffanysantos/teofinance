/// Diz se a descrição de uma linha de extrato é o pagamento de uma fatura de
/// cartão: o débito na conta ("Pagamento de fatura") ou o crédito que aparece
/// na própria fatura ("Pagamento recebido"). As compras do cartão já contam
/// como despesa, então essa linha seria contada duas vezes.
bool pareceTransferenciaDeFatura(String descricao) {
  final d = _semAcento(descricao.toLowerCase());
  return _padroes.any((p) => p.hasMatch(d));
}

final _padroes = [
  RegExp(r'pagamento (de |da |do )?fatura'),
  RegExp(r'pagto\.? (de |da |do )?fatura'),
  RegExp(r'pgto\.? (de |da |do )?fatura'),
  RegExp(r'pag\.? (de |da |do )?fatura'),
  RegExp(r'fatura (do )?cartao'),
  RegExp(r'pagamento (de )?cartao'),
  RegExp(r'pagamento recebido'),
  RegExp(r'pagamento on.?line'),
];

String _semAcento(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final b = StringBuffer();
  for (final c in s.split('')) {
    final i = de.indexOf(c);
    b.write(i >= 0 ? para[i] : c);
  }
  return b.toString();
}
