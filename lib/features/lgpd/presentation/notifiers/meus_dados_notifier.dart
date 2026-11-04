import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/features/lgpd/domain/usecases/excluir_minha_conta_usecase.dart';
import 'package:teofinance/features/lgpd/domain/usecases/exportar_meus_dados_usecase.dart';
import 'package:teofinance/features/lgpd/domain/usecases/zerar_dados_financeiros_usecase.dart';

enum MeusDadosAcao { nenhuma, exportando, excluindo, zerando }

class MeusDadosState {
  const MeusDadosState({this.acao = MeusDadosAcao.nenhuma, this.erro});

  final MeusDadosAcao acao;
  final String? erro;

  bool get ocupado => acao != MeusDadosAcao.nenhuma;
}

class MeusDadosNotifier extends StateNotifier<MeusDadosState> {
  MeusDadosNotifier({
    required ExportarMeusDadosUseCase exportar,
    required ExcluirMinhaContaUseCase excluir,
    required ZerarDadosFinanceirosUseCase zerar,
  })  : _exportar = exportar,
        _excluir = excluir,
        _zerar = zerar,
        super(const MeusDadosState());

  final ExportarMeusDadosUseCase _exportar;
  final ExcluirMinhaContaUseCase _excluir;
  final ZerarDadosFinanceirosUseCase _zerar;

  /// O JSON com todos os dados, ou nulo se falhou (o motivo fica em `erro`).
  Future<String?> exportar() async {
    if (state.ocupado) return null;
    state = const MeusDadosState(acao: MeusDadosAcao.exportando);

    final result = await _exportar();
    return result.fold(
      (falha) {
        state = MeusDadosState(erro: falha.message);
        return null;
      },
      (json) {
        state = const MeusDadosState();
        return json;
      },
    );
  }

  /// `true` quando a conta e os dados foram apagados.
  Future<bool> excluir({required String senha}) async {
    if (state.ocupado) return false;
    state = const MeusDadosState(acao: MeusDadosAcao.excluindo);

    final result = await _excluir(senha: senha);
    return result.fold(
      (falha) {
        state = MeusDadosState(erro: falha.message);
        return false;
      },
      (_) {
        state = const MeusDadosState();
        return true;
      },
    );
  }

  /// `true` quando os dados financeiros foram zerados.
  Future<bool> zerarDadosFinanceiros() async {
    if (state.ocupado) return false;
    state = const MeusDadosState(acao: MeusDadosAcao.zerando);

    final result = await _zerar();
    return result.fold(
      (falha) {
        state = MeusDadosState(erro: falha.message);
        return false;
      },
      (_) {
        state = const MeusDadosState();
        return true;
      },
    );
  }

  void limparErro() => state = MeusDadosState(acao: state.acao);
}
