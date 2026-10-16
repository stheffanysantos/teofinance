import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parcelamento.dart';
import '../../domain/repositories/parcelamento_repository.dart';
import '../../domain/usecases/criar_parcelamento_usecase.dart';

/// Estado do Notifier de parcelamento — lista de parcelamentos do usuário.
class ParcelamentoState {
  final List<Parcelamento> parcelamentos;
  final bool isLoading;
  final String? erro;

  const ParcelamentoState({
    this.parcelamentos = const [],
    this.isLoading = false,
    this.erro,
  });

  ParcelamentoState copyWith({
    List<Parcelamento>? parcelamentos,
    bool? isLoading,
    String? erro,
  }) {
    return ParcelamentoState(
      parcelamentos: parcelamentos ?? this.parcelamentos,
      isLoading: isLoading ?? this.isLoading,
      erro: erro ?? this.erro,
    );
  }
}

/// Notifier para gerenciar parcelamentos — criar, listar, deletar.
class ParcelamentoNotifier extends StateNotifier<ParcelamentoState> {
  final ParcelamentoRepository _repository;
  final CriarParcelamentoUseCase _criarUsecase;

  ParcelamentoNotifier(
    this._repository,
    this._criarUsecase,
  ) : super(const ParcelamentoState());

  /// Cria um novo parcelamento a partir de uma transação.
  Future<void> criarParcelamento({
    required String transacaoId,
    required double totalOriginal,
    required int numeroParcelas,
    required DateTime dataPrimeira,
  }) async {
    state = state.copyWith(isLoading: true, erro: null);

    final params = CriarParcelamentoParams(
      transacaoId: transacaoId,
      totalOriginal: totalOriginal,
      numeroParcelas: numeroParcelas,
      dataPrimeira: dataPrimeira,
    );

    final result = await _criarUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          erro: failure.message,
        );
      },
      (parcelamento) {
        state = state.copyWith(
          isLoading: false,
          parcelamentos: [...state.parcelamentos, parcelamento],
        );
      },
    );
  }

  /// Lista todos os parcelamentos do usuário.
  Future<void> listarParcelamentos(String userId) async {
    state = state.copyWith(isLoading: true, erro: null);

    final result = await _repository.listarPorUsuario(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          erro: failure.message,
        );
      },
      (parcelamentos) {
        state = state.copyWith(
          isLoading: false,
          parcelamentos: parcelamentos,
        );
      },
    );
  }

  /// Deleta um parcelamento e suas transações-filhas.
  Future<void> deletarParcelamento(String parcelamentoId) async {
    state = state.copyWith(isLoading: true, erro: null);

    final result = await _repository.deletarParcelamento(parcelamentoId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          erro: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          parcelamentos: state.parcelamentos
              .where((p) => p.id != parcelamentoId)
              .toList(),
        );
      },
    );
  }
}
