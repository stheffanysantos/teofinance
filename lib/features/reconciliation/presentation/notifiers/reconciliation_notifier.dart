import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

import '../../domain/entities/extrato_linha.dart';
import '../../domain/entities/reconciliation_match.dart';
import '../../domain/repositories/reconciliation_repository.dart';

class ReconciliationState {
  final List<ReconciliationMatch> matches;
  final Map<String, ExtratoLinha> linhas;
  final Map<String, Transacao> transacoes;
  final bool isLoading;
  final String? erro;

  const ReconciliationState({
    this.matches = const [],
    this.linhas = const {},
    this.transacoes = const {},
    this.isLoading = false,
    this.erro,
  });

  ReconciliationState copyWith({
    List<ReconciliationMatch>? matches,
    Map<String, ExtratoLinha>? linhas,
    Map<String, Transacao>? transacoes,
    bool? isLoading,
    String? erro,
    bool limparErro = false,
  }) {
    return ReconciliationState(
      matches: matches ?? this.matches,
      linhas: linhas ?? this.linhas,
      transacoes: transacoes ?? this.transacoes,
      isLoading: isLoading ?? this.isLoading,
      erro: limparErro ? null : (erro ?? this.erro),
    );
  }

  int get totalMatched => matches.where((m) => m.isMatched).length;
  int get totalOrphans => matches.where((m) => m.isOrphan).length;
  int get totalUnmatched => matches.where((m) => m.status == 'unmatched').length;

  double get percentualReconciliado {
    final total = matches.length;
    if (total == 0) return 0;
    return (totalMatched / total) * 100;
  }
}

class ReconciliationNotifier extends StateNotifier<ReconciliationState> {
  final ReconciliationRepository _repository;

  ReconciliationNotifier(this._repository) : super(const ReconciliationState());

  Future<void> fazerReconciliacao({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    state = state.copyWith(isLoading: true, limparErro: true);

    final result = await _repository.fazerMatching(
      userId: userId,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, erro: failure.message),
      (r) => state = state.copyWith(
        isLoading: false,
        matches: r.matches,
        linhas: r.linhas,
        transacoes: r.transacoes,
      ),
    );
  }

  Future<void> aprovarMatch(String matchId) async {
    final result = await _repository.aprovarMatch(matchId);
    result.fold(
      (failure) => state = state.copyWith(erro: failure.message),
      (_) => _atualizarStatus(matchId, 'manual_matched'),
    );
  }

  Future<void> rejeitarMatch(String matchId) async {
    final result = await _repository.rejeitarMatch(matchId);
    result.fold(
      (failure) => state = state.copyWith(erro: failure.message),
      (_) => state = state.copyWith(
        matches: state.matches.where((m) => m.id != matchId).toList(),
      ),
    );
  }

  void _atualizarStatus(String matchId, String status) {
    final updated = state.matches
        .map((m) => m.id == matchId
            ? ReconciliationMatch(
                id: m.id,
                transacaoId: m.transacaoId,
                linhaExtratoId: m.linhaExtratoId,
                dataReconciliacao: m.dataReconciliacao,
                status: status,
                confidence: m.confidence,
              )
            : m)
        .toList();
    state = state.copyWith(matches: updated);
  }
}
