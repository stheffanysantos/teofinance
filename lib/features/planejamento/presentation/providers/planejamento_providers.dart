import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/features/budget/presentation/providers/budget_providers.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/presentation/providers/cartao_providers.dart';
import 'package:teofinance/features/contas/presentation/providers/conta_providers.dart';
import 'package:teofinance/features/investimento/presentation/providers/investimento_providers.dart';
import 'package:teofinance/features/planejamento/domain/services/a_pagar_no_proximo_mes.dart';
import 'package:teofinance/features/planejamento/domain/services/calcular_plano.dart';
import 'package:teofinance/features/planejamento/domain/services/cobertura_da_reserva.dart';
import 'package:teofinance/features/planejamento/domain/services/historico_de_gastos.dart';
import 'package:teofinance/features/planejamento/domain/services/projetar_fluxo_de_caixa.dart';
import 'package:teofinance/features/planejamento/domain/services/ritmo_do_mes.dart';
import 'package:teofinance/features/planejamento/domain/services/simular_parcelamento.dart';
import 'package:teofinance/features/renda/presentation/providers/renda_providers.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

/// Quanto do salário o usuário quer separar para guardar/investir (0 a 1).
final percentualGuardarProvider = StateProvider<double>((ref) => 0.2);

final salarioMensalProvider = Provider<double>((ref) {
  return salarioMensal(ref.watch(rendasStreamProvider).valueOrNull ?? const []);
});

final historicoDeGastosProvider = Provider<HistoricoDeGastos>((ref) {
  return calcularHistoricoDeGastos(
    ref.watch(transacoesStreamProvider).valueOrNull ?? const [],
    hoje: DateTime.now(),
  );
});

/// O que as contas a pagar deste mês já comprometem, por categoria (pagas ou não).
final contasFixasDoMesProvider = Provider<Map<String, double>>((ref) {
  final hoje = DateTime.now();
  final porCategoria = <String, double>{};
  for (final c in ref.watch(contasStreamProvider).valueOrNull ?? const []) {
    if (c.vencimento.year != hoje.year || c.vencimento.month != hoje.month) continue;
    final categoria = c.categoria.trim().isEmpty ? kCategoriaOutros : c.categoria.trim();
    porCategoria.update(categoria, (v) => v + (c.valorPago ?? c.valor), ifAbsent: () => c.valorPago ?? c.valor);
  }
  return porCategoria;
});

/// O plano do mês; nulo enquanto não há salário fixo cadastrado.
final planoDoMesProvider = Provider<PlanoDoMes?>((ref) {
  final salario = ref.watch(salarioMensalProvider);
  if (salario <= 0) return null;
  return calcularPlanoDoMes(
    salario: salario,
    percentualGuardar: ref.watch(percentualGuardarProvider),
    historico: ref.watch(historicoDeGastosProvider),
    contasFixasPorCategoria: ref.watch(contasFixasDoMesProvider),
  );
});

final ritmoDoMesProvider = Provider<List<RitmoDoEnvelope>>((ref) {
  final resumo = ref.watch(resumoOrcamentoProvider).valueOrNull;
  if (resumo == null) return const [];
  return avaliarRitmo(envelopes: resumo.envelopes, hoje: DateTime.now());
});

/// O "saldo na conta" da Home: saldo total mais o que já foi gasto no crédito e
/// ainda não saiu da conta.
final saldoNaContaProvider = Provider<double>((ref) {
  final transacoes = ref.watch(transacoesStreamProvider).valueOrNull ?? const [];
  final saldoTotal = transacoes.fold(0.0, (a, t) => a + t.valorNoSaldo);
  return saldoTotal + (ref.watch(faturasEmAbertoTotalProvider) ?? 0);
});

final fluxoDeCaixaProvider = Provider<FluxoDeCaixa>((ref) {
  return projetarFluxoDeCaixa(
    saldoInicial: ref.watch(saldoNaContaProvider),
    hoje: DateTime.now(),
    rendas: ref.watch(rendasStreamProvider).valueOrNull ?? const [],
    contas: ref.watch(contasStreamProvider).valueOrNull ?? const [],
    faturas: ref.watch(proximasFaturasProvider),
  );
});

/// O que vence no mês seguinte: a parte do usuário nos cartões mais as contas.
final aPagarNoProximoMesProvider = Provider<APagarNoProximoMes>((ref) {
  return calcularAPagarNoProximoMes(
    hoje: DateTime.now(),
    faturas: ref.watch(proximasFaturasProvider),
    contas: ref.watch(contasStreamProvider).valueOrNull ?? const [],
  );
});

final coberturaDaReservaProvider = Provider<CoberturaDaReserva>((ref) {
  return calcularCoberturaDaReserva(
    investimentos: ref.watch(investimentosProvider).valueOrNull ?? const [],
    historico: ref.watch(historicoDeGastosProvider),
  );
});

// ---- Simulador de compra parcelada -------------------------------------------

final valorSimuladoProvider = StateProvider.autoDispose<double>((ref) => 0);
final parcelasSimuladasProvider = StateProvider.autoDispose<int>((ref) => 6);

/// Nulo = o primeiro cartão cadastrado.
final cartaoSimuladoProvider = StateProvider.autoDispose<String?>((ref) => null);

/// O cartão escolhido no simulador (ou o primeiro), nulo se não há cartão.
final cartaoDoSimuladorProvider = Provider.autoDispose<Cartao?>((ref) {
  final cartoes = ref.watch(cartoesProvider).valueOrNull ?? const [];
  if (cartoes.isEmpty) return null;
  final id = ref.watch(cartaoSimuladoProvider);
  return cartoes.where((c) => c.id == id).firstOrNull ?? cartoes.first;
});

final simulacaoProvider = Provider.autoDispose<SimulacaoDeParcelamento?>((ref) {
  final cartao = ref.watch(cartaoDoSimuladorProvider);
  final valor = ref.watch(valorSimuladoProvider);
  if (cartao == null || valor <= 0) return null;
  return simularParcelamento(
    valor: valor,
    parcelas: ref.watch(parcelasSimuladasProvider),
    cartao: cartao,
    dataCompra: DateTime.now(),
    faturas: ref.watch(proximasFaturasProvider),
  );
});
