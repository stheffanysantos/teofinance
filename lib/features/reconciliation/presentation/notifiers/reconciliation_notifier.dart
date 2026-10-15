import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/reconciliation_repository.dart';
import '../../domain/entities/reconciliation_match.dart';

class ReconciliationState {
  final List<ReconciliationMatch> matches;
  final bool isLoading;
  final String? erro;
  final int totalMatched;
  final int totalOrphans;
  final int totalUnmatched;

  const ReconciliationState({
    this.matches = const [],
    this.isLoading = false,
    this.erro,
    this.totalMatched = 0,
    this.totalOrphans = 0,
    this.totalUnmatched = 0,
  });

  ReconciliationState copyWith({
    List<ReconciliationMatch>? matches,
    bool? isLoading,
    String? erro,
    int? totalMatched,
    int? totalOrphans,
    int? totalUnmatched,
  }) {
    return ReconciliationState(
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      erro: erro ?? this.erro,
      totalMatched: totalMatched ?? this.totalMatched,
      totalOrphans: totalOrphans ?? this.totalOrphans,
      totalUnmatched: totalUnmatched ?? this.totalUnmatched,
    );
  }

  double get percentualReconciliado {
    final total = matches.length;
    if (total == 0) return 0;
    return (totalMatched / total) * 100;
  }
}

class ReconciliationNotifier extends StateNotifier<ReconciliationState> {
  final ReconciliationRepository _repository;

  ReconciliationNotifier(this._repository)
      : super(const ReconciliationState());

  Future<void> fazerReconciliacao({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    state = state.copyWith(isLoading: true, erro: null);

    final result = await _repository.fazerMatching(
      userId: userId,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        erro: failure.message,
      ),
      (matches) {
        final matched = matches.where((m) => m.isMatched).length;
        final orphans = matches.where((m) => m.isOrphan).length;
        final unmatched = matches.where((m) => m.status == 'unmatched').length;

        state = state.copyWith(
          isLoading: false,
          matches: matches,
          totalMatched: matched,
          totalOrphans: orphans,
          totalUnmatched: unmatched,
        );
      },
    );
  }

  Future<void> aprovarMatch(String matchId) async {
    final result = await _repository.aprovarMatch(matchId);
    result.fold(
      (failure) => state = state.copyWith(erro: failure.message),
      (_) {
        // Atualiza match localmente
        final updated = state.matches
            .map((m) => m.id == matchId
                ? ReconciliationMatch(
                    id: m.id,
                    transacaoId: m.transacaoId,
                    linhaExtratoId: m.linhaExtratoId,
                    dataReconciliacao: m.dataReconciliacao,
                    status: 'manual_matched',
                    confidence: m.confidence,
                  )
                : m)
            .toList();
        state = state.copyWith(matches: updated);
      },
    );
  }

  Future<void> rejeitarMatch(String matchId) async {
    final result = await _repository.rejeitarMatch(matchId);
    result.fold(
      (failure) => state = state.copyWith(erro: failure.message),
      (_) {
        final updated = state.matches
            .map((m) => m.id == matchId
                ? ReconciliationMatch(
                    id: m.id,
                    transacaoId: m.transacaoId,
                    linhaExtratoId: m.linhaExtratoId,
                    dataReconciliacao: m.dataReconciliacao,
                    status: 'unmatched',
                    confidence: m.confidence,
                  )
                : m)
            .toList();
        state = state.copyWith(matches: updated);
      },
    );
  }
}
