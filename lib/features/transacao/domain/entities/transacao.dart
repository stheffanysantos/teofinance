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
