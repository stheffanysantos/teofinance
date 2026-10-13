import '../../../../core/sync/sync_status.dart';

/// Meta de Investimento (ver `.claude/memory/domain-glossary.md`): objetivo
/// financeiro com valor-alvo, prazo e progresso visual — distinta de
/// `Renda`/`Transacao`.
class Meta {
  const Meta({
    required this.id,
    required this.nome,
    required this.valorAtual,
    required this.valorAlvo,
    required this.prazo,
    this.remoteId,
    this.syncStatus = SyncStatus.pendingCreate,
  });

  final String id;
  final String nome;
  final double valorAtual;
  final double valorAlvo;
  final DateTime prazo;
  final String? remoteId;
  final SyncStatus syncStatus;

  double get progresso => valorAlvo <= 0 ? 0 : (valorAtual / valorAlvo).clamp(0.0, 1.0);
  int get percentual => (progresso * 100).round();

  /// Aporte mensal necessário para chegar ao valor-alvo até o prazo,
  /// assumindo contribuições iguais todo mês a partir de hoje.
  double get aporteMensalSugerido {
    final faltam = valorAlvo - valorAtual;
    if (faltam <= 0) return 0;
    final hoje = DateTime.now();
    final meses = (prazo.year - hoje.year) * 12 + (prazo.month - hoje.month);
    if (meses <= 0) return faltam;
    return faltam / meses;
  }
}
