/// Uma linha do extrato já traduzida pelo `PerfilBanco` — ainda em memória,
/// não persistida (passo 5 do fluxo; persiste só após revisão e confirmação
/// do usuário no passo 7).
class TransacaoImportada {
  const TransacaoImportada({
    required this.data,
    required this.descricao,
    required this.valor,
    this.categoria,
    this.fitid,
  });

  final DateTime data;
  final String descricao;
  final double valor;
  final String? categoria;

  /// `FITID` do OFX: identificador único do lançamento no banco. Nulo no CSV.
  final String? fitid;

  bool get precisaCategoria => categoria == null || categoria!.trim().isEmpty;
}
