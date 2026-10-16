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

  ({String userId, DateTime inicio, DateTime fim})? _periodo;

  Future<void> fazerReconciliacao({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    _periodo = (userId: userId, inicio: dataInicio, fim: dataFim);
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

  /// Liga uma linha do extrato (normalmente órfã) a uma transação escolhida
  /// pelo usuário e recalcula o período para refletir quem ficou livre.
  Future<void> vincularManualmente({
    required String transacaoId,
    required String linhaExtratoId,
  }) async {
    final result = await _repository.criarMatchManual(
      transacaoId: transacaoId,
      linhaExtratoId: linhaExtratoId,
    );

    final periodo = _periodo;
    await result.fold(
      (failure) async => state = state.copyWith(erro: failure.message),
      (_) async {
        if (periodo == null) return;
        await fazerReconciliacao(
          userId: periodo.userId,
          dataInicio: periodo.inicio,
          dataFim: periodo.fim,
        );
      },
    );
  }

  /// Transações do período que ainda podem ser ligadas a [linha], da mais
  /// parecida (valor e data) para a menos.
  List<Transacao> candidatasPara(ExtratoLinha linha) {
    final ocupadas = state.matches
        .where((m) => m.isMatched)
        .map((m) => m.transacaoId)
        .whereType<String>()
        .toSet();

    final candidatas = state.transacoes.values.where((t) => !ocupadas.contains(t.id)).toList();
    candidatas.sort((a, b) {
      final porValor = (a.valorCobrado - linha.valorAsTransacao)
          .abs()
          .compareTo((b.valorCobrado - linha.valorAsTransacao).abs());
      if (porValor != 0) return porValor;
      return a.data
          .difference(linha.data)
          .abs()
          .compareTo(b.data.difference(linha.data).abs());
    });
    return candidatas;
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
