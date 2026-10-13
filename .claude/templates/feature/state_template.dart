import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:teofinance/features/nome_feature/domain/entities/nome_entidade.dart';

part 'nome_entidade_list_state.freezed.dart';

/// Único State (union freezed) por Notifier — nunca campos soltos de estado mutável.
@freezed
class NomeEntidadeListState with _$NomeEntidadeListState {
  const factory NomeEntidadeListState.inicial() = _Inicial;
  const factory NomeEntidadeListState.carregando() = _Carregando;
  const factory NomeEntidadeListState.dados(List<NomeEntidade> itens) = _Dados;
  const factory NomeEntidadeListState.vazio() = _Vazio;
  const factory NomeEntidadeListState.erro(String mensagem) = _Erro;
}
