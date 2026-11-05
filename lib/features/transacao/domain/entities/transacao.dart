import '../../../../core/sync/sync_status.dart';

/// Uma transação persistida (seja por importação de extrato, seja
/// cadastrada manualmente) — ver `.claude/plans/MVP.md`, item 4.
/// Pode ser uma transação normal ou uma parcela de um parcelamento
/// (ver `.claude/plans/Sprint02-Parcelamento.md`).
class Transacao {
  const Transacao({
    required this.id,
    required this.descricao,
    required this.categoria,
    required this.valor,
    required this.data,
    this.remoteId,
    this.syncStatus = SyncStatus.pendingCreate,
    // Campos de parcelamento (nulos se não é uma parcela)
    this.parcelamentoId,
    this.numeroParcela,
    this.valorParcela,
    this.ehParcela = false,
    this.statusParcela,
    this.minhaParte,
    this.divididoCom = const [],
    this.cartaoId,
  });

  final String id;
  final String descricao;

  /// Vazio = sem categoria (precisa de categorização manual).
  final String categoria;
  final double valor;
  final DateTime data;

  /// Id do documento no Firestore; nulo até a primeira sincronização.
  final String? remoteId;
  final SyncStatus syncStatus;

  /// Parcelamento: campos adicionados na v5 do Drift (Sprint 02)
  final String? parcelamentoId;
  final int? numeroParcela;
  final double? valorParcela;
  final bool ehParcela;
  final String? statusParcela;

  /// Divisão de despesa: parte do usuário no total cobrado (positiva); nula
  /// se a compra não foi dividida.
  final double? minhaParte;
  final List<String> divididoCom;

  /// Cartão de crédito em que a compra foi feita; nulo = sem cartão.
  final String? cartaoId;

  /// O que entra no "Saldo total": o valor da transação, mas, numa compra
  /// dividida, só a parte do usuário (o resto é de quem dividiu).
  double get valorNoSaldo => ehDividida ? valorContabilizado : valor;

  /// Marca, antes do nome em [divididoCom], de quem já devolveu a sua parte.
  /// Fica na própria lista (que já sincroniza) para não precisar de outra coluna.
  static const marcaReembolso = '✓ ';

  static String _semMarca(String nome) => nome.startsWith(marcaReembolso) ? nome.substring(marcaReembolso.length) : nome;

  /// Pessoas da divisão, sem a marca de reembolso.
  List<String> get pessoasDaDivisao => divididoCom.map(_semMarca).toList();

  /// Pessoas da divisão que ainda não devolveram a parte delas.
  List<String> get pessoasPendentes => [
    for (final n in divididoCom)
      if (!n.startsWith(marcaReembolso)) n,
  ];

  bool jaPagou(String pessoa) => divididoCom.contains('$marcaReembolso$pessoa');

  /// Quanto cada pessoa deve: o que não é a parte do usuário, dividido igualmente.
  double get parteDeCadaPessoa {
    if (!ehDividida || divididoCom.isEmpty) return 0;
    return (valorCobrado.abs() - minhaParte!) / divididoCom.length;
  }

  /// Quanto ainda falta receber desta compra.
  double get aReceber => parteDeCadaPessoa * pessoasPendentes.length;

  /// Lista com [pessoa] marcada (ou desmarcada) como quem já pagou.
  List<String> divisaoComReembolso(String pessoa, {required bool pago}) => [
    for (final n in divididoCom)
      if (_semMarca(n) != pessoa) n else (pago ? '$marcaReembolso$pessoa' : pessoa),
  ];

  /// Ao editar a divisão, mantém a marca de quem já pagou e continua na lista.
  List<String> preservandoReembolsos(List<String> novasPessoas) => [
    for (final p in novasPessoas) jaPagou(p) ? '$marcaReembolso$p' : p,
  ];

  bool get precisaCategoria => categoria.trim().isEmpty;
  bool get isReceita => valor > 0;

  bool get ehDividida => minhaParte != null;

  /// O que o banco efetivamente cobra (total da compra ou da parcela) — é este
  /// valor que aparece no extrato e que a reconciliação compara.
  double get valorCobrado => ehParcela ? (valorParcela ?? valor) : valor;

  /// O que pesa no bolso do usuário: a parte dele quando a compra foi
  /// dividida, senão o valor cobrado. Usado por dashboard e listagens.
  double get valorContabilizado {
    final cobrado = valorCobrado;
    if (minhaParte == null) return cobrado;
    return cobrado < 0 ? -minhaParte! : minhaParte!;
  }
}
