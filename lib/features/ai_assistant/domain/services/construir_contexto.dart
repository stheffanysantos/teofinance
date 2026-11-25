import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/contexto_financeiro.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/services/calcular_envelopes.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/cartao/domain/services/resumo_faturas.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/meta/domain/entities/meta.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

const _mesesDeHistorico = 3;

/// Reduz os dados das outras features ao agregado do mês [mes]: totais, os
/// meses anteriores, cartões e faturas, reembolsos a receber, contas a pagar,
/// investimentos e parcelas futuras. Nunca devolve transações individuais.
ContextoFinanceiro construirContexto({
  required List<Transacao> transacoes,
  required List<Orcamento> limites,
  required List<Meta> metas,
  required DateTime mes,
  List<Cartao> cartoes = const [],
  List<FaturaPaga> pagamentos = const [],
  List<ContaAPagar> contas = const [],
  List<Investimento> investimentos = const [],
}) {
  final hoje = DateTime(mes.year, mes.month, mes.day);
  final atual = _totais(transacoes, mes.year, mes.month);

  final historico = <MesResumo>[];
  for (var i = 1; i <= _mesesDeHistorico; i++) {
    final ref = DateTime(mes.year, mes.month - i);
    final t = _totais(transacoes, ref.year, ref.month);
    if (t.receitas == 0 && t.despesas == 0) continue;
    historico.add(
      MesResumo(mes: ref, receitas: t.receitas, despesas: t.despesas),
    );
  }

  // Quanto cada pessoa ainda deve (soma de todas as compras divididas).
  final reembolsos = <String, double>{};
  for (final t in transacoes) {
    if (!t.ehDividida) continue;
    for (final pessoa in t.pessoasPendentes) {
      reembolsos.update(
        pessoa,
        (v) => v + t.parteDeCadaPessoa,
        ifAbsent: () => t.parteDeCadaPessoa,
      );
    }
  }

  final resumoCartoes = <CartaoResumoIa>[];
  for (final c in cartoes) {
    final faturas = resumirFaturas(
      cartao: c,
      transacoes: transacoes,
      pagamentos: pagamentos,
    );
    final abertas = faturas.where((f) => f.emAberto).toList();
    resumoCartoes.add(
      CartaoResumoIa(
        nome: c.nome,
        faturaAberta: abertas.fold(0.0, (a, f) => a + f.total),
        vencimento: abertas.isEmpty ? null : abertas.first.periodo.vencimento,
        vencida: abertas.any((f) => f.vencidaEm(hoje)),
        limite: c.limite,
        faturasPagas: faturas.where((f) => f.paga != null).length,
      ),
    );
  }

  final emAberto = contas.where((c) => !c.paga).toList()
    ..sort((a, b) => a.vencimento.compareTo(b.vencimento));

  var parcelas = 0;
  var valorParcelas = 0.0;
  for (final t in transacoes) {
    if (t.ehParcela && t.data.isAfter(hoje)) {
      parcelas++;
      valorParcelas -= t.valorNoSaldo;
    }
  }

  return ContextoFinanceiro(
    mes: mes,
    hoje: hoje,
    receitas: atual.receitas,
    despesas: atual.despesas,
    gastoPorCategoria: atual.porCategoria,
    envelopes: calcularEnvelopes(
      limites: limites,
      transacoes: transacoes,
      mes: mes,
    ).envelopes,
    metas: metas,
    historico: historico,
    cartoes: resumoCartoes,
    faturasPorMes: projetarFaturasPorMes(cartoes: cartoes, transacoes: transacoes, pagamentos: pagamentos, hoje: hoje),
    reembolsos: reembolsos,
    contasAPagar: emAberto,
    investimentos: investimentos,
    parcelasFuturas: parcelas,
    valorParcelasFuturas: valorParcelas,
  );
}

({double receitas, double despesas, Map<String, double> porCategoria}) _totais(
  List<Transacao> transacoes,
  int ano,
  int mes,
) {
  var receitas = 0.0;
  var despesas = 0.0;
  final porCategoria = <String, double>{};

  for (final t in transacoes) {
    if (t.data.year != ano || t.data.month != mes) continue;
    if (t.categoria == kCategoriaAjusteSaldo) continue;
    final valor = t.valorContabilizado;
    if (valor > 0) {
      receitas += valor;
    } else if (valor < 0) {
      despesas -= valor;
      final categoria = t.categoria.trim().isEmpty
          ? 'Sem categoria'
          : t.categoria;
      porCategoria.update(
        categoria,
        (atual) => atual - valor,
        ifAbsent: () => -valor,
      );
    }
  }
  return (receitas: receitas, despesas: despesas, porCategoria: porCategoria);
}
