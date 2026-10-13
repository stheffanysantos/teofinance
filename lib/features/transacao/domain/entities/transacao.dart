import '../../../../core/sync/sync_status.dart';

/// Uma transação persistida (seja por importação de extrato, seja
/// cadastrada manualmente) — ver `.claude/plans/MVP.md`, item 4.
class Transacao {
  const Transacao({
    required this.id,
    required this.descricao,
    required this.categoria,
    required this.valor,
    required this.data,
    this.remoteId,
    this.syncStatus = SyncStatus.pendingCreate,
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

  bool get precisaCategoria => categoria.trim().isEmpty;
  bool get isReceita => valor > 0;
}
