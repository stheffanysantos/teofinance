import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/investimento/domain/entities/investimento.dart';
import 'package:teofinance/features/planejamento/domain/services/calcular_plano.dart';
import 'package:teofinance/features/planejamento/domain/services/cobertura_da_reserva.dart';
import 'package:teofinance/features/planejamento/domain/services/historico_de_gastos.dart';
import 'package:teofinance/features/planejamento/domain/services/projetar_fluxo_de_caixa.dart';
import 'package:teofinance/features/planejamento/domain/services/ritmo_do_mes.dart';
import 'package:teofinance/features/planejamento/domain/services/simular_parcelamento.dart';
import 'package:teofinance/features/renda/domain/entities/renda.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

final _hoje = DateTime(2026, 11, 12);

Transacao _gasto(String categoria, double valor, DateTime data, {double? minhaParte, List<String> com = const []}) =>
    Transacao(
      id: '$categoria-$valor-${data.millisecondsSinceEpoch}',
      descricao: categoria,
      categoria: categoria,
      valor: -valor,
      data: data,
      minhaParte: minhaParte,
      divididoCom: com,
    );

void main() {
  group('histórico de gastos', () {
    test('média por categoria dos meses fechados, sem o mês atual', () {
      final h = calcularHistoricoDeGastos(
        hoje: _hoje,
        [
          _gasto('Lazer', 100, DateTime(2026, 10, 5)),
          _gasto('Lazer', 300, DateTime(2026, 9, 5)),
          _gasto('Mercado', 600, DateTime(2026, 10, 6)),
          _gasto('Lazer', 9999, DateTime(2026, 11, 2)), // mês atual: fora
          _gasto('Lazer', 9999, DateTime(2026, 7, 2)), // antes da janela: fora
        ],
      );

      expect(h.mesesComDados, 2);
      expect(h.mediaPorCategoria['Lazer'], 200); // (100 + 300) / 2
      expect(h.mediaPorCategoria['Mercado'], 300); // 600 / 2
    });

    test('compra dividida conta só a parte do usuário e sem categoria vira Outros', () {
      final h = calcularHistoricoDeGastos(
        hoje: _hoje,
        [
          _gasto('Lazer', 156, DateTime(2026, 10, 10), minhaParte: 78, com: const ['Mãe']),
          _gasto('', 40, DateTime(2026, 10, 11)),
        ],
      );

      expect(h.mediaPorCategoria['Lazer'], 78);
      expect(h.mediaPorCategoria[kCategoriaOutros], 40);
    });

    test('sem despesas antigas não há dados', () {
      expect(calcularHistoricoDeGastos(const [], hoje: _hoje).semDados, isTrue);
    });
  });

  group('plano do mês', () {
    const historico = HistoricoDeGastos(
      mesesComDados: 3,
      mediaPorCategoria: {'Moradia': 2000, 'Mercado': 800, 'Lazer': 600, 'Vestuário': 400},
    );

    test('o salário fixo ignora renda variável e inativa, e converte semanal e anual', () {
      final s = salarioMensal([
        Renda(id: '1', descricao: 'Salário', valor: 5000, tipo: TipoRenda.fixa, dataRecebimento: _hoje, recorrencia: RecorrenciaRenda.mensal),
        Renda(id: '2', descricao: 'Freela', valor: 900, tipo: TipoRenda.variavel, dataRecebimento: _hoje),
        Renda(id: '3', descricao: 'Antiga', valor: 700, tipo: TipoRenda.fixa, dataRecebimento: _hoje, recorrencia: RecorrenciaRenda.mensal, ativa: false),
        Renda(id: '4', descricao: 'Aluguel', valor: 1200, tipo: TipoRenda.fixa, dataRecebimento: _hoje, recorrencia: RecorrenciaRenda.anual),
      ]);

      expect(s, 5100); // 5000 + 1200 / 12
    });

    test('cabendo tudo, os limites são o que a pessoa já gasta e sobra folga', () {
      final p = calcularPlanoDoMes(salario: 6000, percentualGuardar: 0.2, historico: historico);

      expect(p.metaGuardar, 1200);
      expect(p.disponivel, 4800);
      expect(p.viavel, isTrue);
      expect(p.folga, 1000); // 4800 - 3800
      expect(p.linhas.firstWhere((l) => l.categoria == 'Lazer').limiteSugerido, 600);
      expect(p.totalLimites, 3800);
    });

    test('não cabendo, só as categorias flexíveis são cortadas e as essenciais ficam', () {
      // disponível 3300 contra 3800 de gasto: faltam 500 a cortar de Lazer + Vestuário.
      final p = calcularPlanoDoMes(salario: 4125, percentualGuardar: 0.2, historico: historico);

      expect(p.viavel, isTrue);
      expect(p.folga, 0);
      final moradia = p.linhas.firstWhere((l) => l.categoria == 'Moradia');
      final mercado = p.linhas.firstWhere((l) => l.categoria == 'Mercado');
      expect(moradia.limiteSugerido, 2000, reason: 'essencial não corta');
      expect(mercado.limiteSugerido, 800, reason: 'essencial não corta');
      final lazer = p.linhas.firstWhere((l) => l.categoria == 'Lazer');
      final roupas = p.linhas.firstWhere((l) => l.categoria == 'Vestuário');
      expect(lazer.limiteSugerido + roupas.limiteSugerido, closeTo(500, 1), reason: 'sobra 1000 - 500 cortados');
      expect(lazer.corte, greaterThan(0));
      expect(p.totalLimites, closeTo(3300, 2));
    });

    test('um corte além do piso não é feito: falta cobrir e mostra o máximo que dá para guardar', () {
      // disponível 2400; essenciais 2800 sozinhos já passam disso.
      final p = calcularPlanoDoMes(salario: 3000, percentualGuardar: 0.2, historico: historico);

      expect(p.viavel, isFalse);
      expect(p.faltaCobrir, greaterThan(0));
      for (final l in p.linhas.where((l) => !l.essencial)) {
        expect(l.limiteSugerido, greaterThanOrEqualTo((l.mediaHistorica * kPisoFlexivel).floorToDouble()));
      }
      expect(p.guardarPossivel, lessThan(p.metaGuardar));
    });

    test('contas fixas do mês seguram o piso da categoria', () {
      final p = calcularPlanoDoMes(
        salario: 6000,
        percentualGuardar: 0.2,
        historico: const HistoricoDeGastos(mesesComDados: 3, mediaPorCategoria: {'Lazer': 100}),
        contasFixasPorCategoria: const {'Lazer': 250},
      );

      expect(p.linhas.single.limiteSugerido, 250);
    });

    test('guardar 0% deixa o salário inteiro disponível', () {
      final p = calcularPlanoDoMes(salario: 6000, percentualGuardar: 0, historico: historico);
      expect(p.metaGuardar, 0);
      expect(p.disponivel, 6000);
    });
  });

  group('ritmo do mês', () {
    EnvelopeOrcamento env(String c, double limite, double gasto) =>
        EnvelopeOrcamento(orcamento: Orcamento(id: c, categoria: c, limite: limite), gasto: gasto);

    test('gastar 70% do limite no dia 12 de 30 é acelerado; estourado vem primeiro', () {
      final r = avaliarRitmo(
        hoje: DateTime(2026, 11, 12),
        envelopes: [env('Mercado', 1000, 300), env('Lazer', 400, 280), env('Transporte', 300, 320)],
      );

      expect(r.map((e) => e.categoria), ['Transporte', 'Lazer', 'Mercado']);
      expect(r[0].situacao, SituacaoRitmo.estourado);
      expect(r[1].situacao, SituacaoRitmo.acelerado);
      expect(r[1].previsto, closeTo(700, 0.01)); // 280 / (12/30)
      expect(r[1].excedentePrevisto, closeTo(300, 0.01));
      expect(r[2].situacao, SituacaoRitmo.ok);
    });

    test('no início do mês não projeta, para não dar alarme falso', () {
      final r = avaliarRitmo(hoje: DateTime(2026, 11, 2), envelopes: [env('Lazer', 400, 250)]);
      expect(r.single.situacao, SituacaoRitmo.ok);
      expect(r.single.previsto, 250);
    });

    test('gastar no ritmo do calendário é ok', () {
      final r = avaliarRitmo(hoje: DateTime(2026, 11, 15), envelopes: [env('Lazer', 400, 200)]);
      expect(r.single.situacao, SituacaoRitmo.ok);
    });
  });

  group('fluxo de caixa', () {
    const nubank = Cartao(id: 'nu', nome: 'Nubank', diaFechamento: 25, diaVencimento: 5);

    test('soma salário, contas e fatura nas datas certas e acha o menor saldo', () {
      final fluxo = projetarFluxoDeCaixa(
        saldoInicial: 1000,
        hoje: _hoje, // 12/11
        horizonteDias: 30,
        rendas: [
          Renda(id: 's', descricao: 'Salário', valor: 5000, tipo: TipoRenda.fixa, dataRecebimento: DateTime(2026, 11, 30), recorrencia: RecorrenciaRenda.mensal),
        ],
        contas: [
          ContaAPagar(id: 'a', descricao: 'Aluguel', valor: 1500, vencimento: DateTime(2026, 11, 20), diaBase: 20),
        ],
        faturas: [
          MesDeFaturas(ano: 2026, mes: 12, faturas: [
            FaturaDoCartaoNoMes(cartao: nubank, total: 800, minhaParte: 800, vencimento: DateTime(2026, 12, 5), vencida: false),
          ]),
        ],
      );

      // 12/11: 1000 -> 20/11 aluguel: -500 -> 30/11 salário: 4500 -> 05/12 fatura: 3700
      expect(fluxo.dias.map((d) => d.saldo), [-500, 4500, 3700]);
      expect(fluxo.menorSaldo!.data, DateTime(2026, 11, 20));
      expect(fluxo.primeiraFalta!.data, DateTime(2026, 11, 20), reason: 'o dinheiro acaba antes do salário');
      expect(fluxo.saldoFinal, 3700);
    });

    test('salário mensal se repete dentro do horizonte e começa no próximo recebimento', () {
      final fluxo = projetarFluxoDeCaixa(
        saldoInicial: 0,
        hoje: _hoje,
        horizonteDias: 60,
        // Cadastrado em setembro: o próximo é 05/12, depois 05/01.
        rendas: [Renda(id: 's', descricao: 'Salário', valor: 100, tipo: TipoRenda.fixa, dataRecebimento: DateTime(2026, 9, 5), recorrencia: RecorrenciaRenda.mensal)],
        contas: const [],
        faturas: const [],
      );

      expect(fluxo.dias.map((d) => d.data), [DateTime(2026, 12, 5), DateTime(2027, 1, 5)]);
    });

    test('conta atrasada sai hoje, paga não entra, e a recorrente repete', () {
      final fluxo = projetarFluxoDeCaixa(
        saldoInicial: 500,
        hoje: _hoje,
        horizonteDias: 60,
        rendas: const [],
        faturas: const [],
        contas: [
          ContaAPagar(id: '1', descricao: 'Atrasada', valor: 100, vencimento: DateTime(2026, 11, 1), diaBase: 1),
          ContaAPagar(id: '2', descricao: 'Paga', valor: 999, vencimento: DateTime(2026, 11, 20), diaBase: 20, paga: true),
          ContaAPagar(id: '3', descricao: 'Internet', valor: 50, vencimento: DateTime(2026, 11, 20), diaBase: 20, recorrencia: RecorrenciaConta.mensal),
        ],
      );

      expect(fluxo.dias.first.data, DateTime(2026, 11, 12), reason: 'a atrasada vira hoje');
      expect(fluxo.dias.first.saldo, 400);
      expect(fluxo.dias.where((d) => d.eventos.any((e) => e.descricao == 'Internet')).length, 2, reason: '20/11 e 20/12; 20/01 passa do horizonte de 60 dias');
      expect(fluxo.dias.any((d) => d.eventos.any((e) => e.descricao == 'Paga')), isFalse);
    });

    test('sem eventos o saldo não muda', () {
      final fluxo = projetarFluxoDeCaixa(saldoInicial: 300, hoje: _hoje, rendas: const [], contas: const [], faturas: const []);
      expect(fluxo.saldoFinal, 300);
      expect(fluxo.menorSaldo, isNull);
      expect(fluxo.primeiraFalta, isNull);
    });
  });

  group('simulador de parcelamento', () {
    const nubank = Cartao(id: 'nu', nome: 'Nubank', diaFechamento: 25, diaVencimento: 5, limite: 1000);

    test('espalha as parcelas pelos meses a partir da fatura da compra e soma ao que já vence', () {
      final s = simularParcelamento(
        valor: 300,
        parcelas: 3,
        cartao: nubank,
        dataCompra: DateTime(2026, 11, 12), // fecha 25/11 -> vence 05/12
        faturas: [
          MesDeFaturas(ano: 2026, mes: 12, faturas: [
            FaturaDoCartaoNoMes(cartao: nubank, total: 200, minhaParte: 200, vencimento: DateTime(2026, 12, 5), vencida: false),
          ]),
        ],
      );

      expect(s.meses.map((m) => (m.ano, m.mes)), [(2026, 12), (2027, 1), (2027, 2)]);
      expect(s.valorDaParcela, 100);
      expect(s.meses.first.depois, 300); // 200 já em dezembro + 100
      expect(s.meses.last.depois, 100);
      expect(s.mesMaisPesado!.mes, 12);
    });

    test('divisão que não fecha põe o resto na última parcela', () {
      final s = simularParcelamento(valor: 100, parcelas: 3, cartao: nubank, dataCompra: _hoje, faturas: const []);
      expect(s.meses.map((m) => m.parcela), [33.33, 33.33, 33.34]);
    });

    test('avisa quando passa do limite do cartão', () {
      final dentro = simularParcelamento(valor: 500, parcelas: 2, cartao: nubank, dataCompra: _hoje, faturas: const []);
      expect(dentro.ultrapassaLimite, isFalse);

      final passa = simularParcelamento(
        valor: 600,
        parcelas: 2,
        cartao: nubank,
        dataCompra: _hoje,
        faturas: [
          MesDeFaturas(ano: 2026, mes: 12, faturas: [
            FaturaDoCartaoNoMes(cartao: nubank, total: 500, minhaParte: 500, vencimento: DateTime(2026, 12, 5), vencida: false),
          ]),
        ],
      );
      expect(passa.usoDoLimiteDepois, 1100);
      expect(passa.ultrapassaLimite, isTrue);
    });

    test('valor ou parcelas inválidos não simulam nada', () {
      expect(simularParcelamento(valor: 0, parcelas: 3, cartao: nubank, dataCompra: _hoje, faturas: const []).meses, isEmpty);
      expect(simularParcelamento(valor: 100, parcelas: 0, cartao: nubank, dataCompra: _hoje, faturas: const []).meses, isEmpty);
    });
  });

  group('reserva de emergência', () {
    Investimento inv(TipoInvestimento tipo, double atual) => Investimento(
          id: '$tipo',
          nome: '$tipo',
          tipo: tipo,
          valorInvestido: atual,
          valorAtual: atual,
          dataAplicacao: DateTime(2026, 1, 1),
        );
    const gasto3k = HistoricoDeGastos(mesesComDados: 3, mediaPorCategoria: {'Tudo': 3000});

    test('só conta investimento de resgate rápido e diz por quantos meses cobre', () {
      final c = calcularCoberturaDaReserva(
        investimentos: [inv(TipoInvestimento.tesouroDireto, 6000), inv(TipoInvestimento.poupanca, 3000), inv(TipoInvestimento.acoes, 50000), inv(TipoInvestimento.cripto, 9000)],
        historico: gasto3k,
      );

      expect(c.reserva, 9000);
      expect(c.meses, 3);
      expect(c.nivel, NivelDaReserva.razoavel);
      expect(c.falta, 9000); // alvo 6 x 3000 = 18000
      expect(c.progresso, 0.5);
    });

    test('níveis: abaixo de 3 meses é baixa, a partir do alvo é sólida', () {
      expect(calcularCoberturaDaReserva(investimentos: [inv(TipoInvestimento.poupanca, 3000)], historico: gasto3k).nivel, NivelDaReserva.baixa);
      final solida = calcularCoberturaDaReserva(investimentos: [inv(TipoInvestimento.poupanca, 20000)], historico: gasto3k);
      expect(solida.nivel, NivelDaReserva.solida);
      expect(solida.falta, 0);
      expect(solida.progresso, 1);
    });

    test('sem histórico de gastos não dá para dizer quantos meses', () {
      final c = calcularCoberturaDaReserva(
        investimentos: [inv(TipoInvestimento.poupanca, 1000)],
        historico: const HistoricoDeGastos(mediaPorCategoria: {}, mesesComDados: 0),
      );
      expect(c.meses, isNull);
      expect(c.nivel, isNull);
    });
  });
}
