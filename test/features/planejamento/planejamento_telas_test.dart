import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/repositories/orcamento_repository.dart';
import 'package:teofinance/features/budget/domain/usecases/definir_limite_orcamento_usecase.dart';
import 'package:teofinance/features/budget/presentation/providers/budget_providers.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/cartao/presentation/providers/cartao_providers.dart';
import 'package:teofinance/features/planejamento/domain/services/a_pagar_no_proximo_mes.dart';
import 'package:teofinance/features/planejamento/domain/services/calcular_plano.dart';
import 'package:teofinance/features/planejamento/domain/services/cobertura_da_reserva.dart';
import 'package:teofinance/features/planejamento/domain/services/historico_de_gastos.dart';
import 'package:teofinance/features/planejamento/domain/services/projetar_fluxo_de_caixa.dart';
import 'package:teofinance/features/planejamento/domain/services/ritmo_do_mes.dart';
import 'package:teofinance/features/planejamento/presentation/providers/planejamento_providers.dart';
import 'package:teofinance/features/planejamento/presentation/screens/a_pagar_no_proximo_mes_screen.dart';
import 'package:teofinance/features/planejamento/presentation/screens/fluxo_de_caixa_screen.dart';
import 'package:teofinance/features/planejamento/presentation/screens/planejamento_screen.dart';
import 'package:teofinance/features/planejamento/presentation/screens/plano_do_mes_screen.dart';
import 'package:teofinance/features/planejamento/presentation/screens/simulador_parcelamento_screen.dart';

class _FakeOrcamentoRepository implements OrcamentoRepository {
  final definidos = <String, double>{};

  @override
  Future<Either<Failure, Orcamento>> definirLimite({required String categoria, required double limite}) async {
    definidos[categoria] = limite;
    return Right(Orcamento(id: categoria, categoria: categoria, limite: limite));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget tela, {List<Override> overrides = const []}) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: AppTheme.light(), home: tela),
    );

PlanoDoMes _plano() => calcularPlanoDoMes(
      salario: 6000,
      percentualGuardar: 0.2,
      historico: const HistoricoDeGastos(
        mesesComDados: 3,
        mediaPorCategoria: {'Moradia': 2000, 'Mercado': 800, 'Lazer': 600},
      ),
    );

APagarNoProximoMes _aPagar() => APagarNoProximoMes(
      ano: 2026,
      mes: 12,
      cartoes: 600,
      contas: 1500,
      itens: [
        ItemAPagar(descricao: 'Aluguel', vencimento: DateTime(2026, 12, 10), valor: 1500, tipo: TipoItemAPagar.conta),
        ItemAPagar(descricao: 'Fatura Nubank', vencimento: DateTime(2026, 12, 5), valor: 600, tipo: TipoItemAPagar.cartao),
      ],
    );

void main() {
  testWidgets('A pagar no mês seguinte lista as faturas e as contas', (tester) async {
    await tester.pumpWidget(_app(const APagarNoProximoMesScreen(), overrides: [aPagarNoProximoMesProvider.overrideWithValue(_aPagar())]));

    expect(find.text('A pagar em dezembro'), findsOneWidget);
    expect(find.text('Aluguel'), findsOneWidget);
    expect(find.text('Fatura Nubank'), findsOneWidget);
    expect(find.text('R\$ 2.100,00'), findsOneWidget);
  });

  testWidgets('Planejamento mostra os quatro indicadores', (tester) async {
    final fluxoComFalta = projetarFluxoDeCaixa(
      saldoInicial: 100,
      hoje: DateTime(2026, 11, 12),
      rendas: const [],
      faturas: const [],
      contas: const [],
    );
    await tester.pumpWidget(
      _app(
        const PlanejamentoScreen(),
        overrides: [
          planoDoMesProvider.overrideWithValue(_plano()),
          aPagarNoProximoMesProvider.overrideWithValue(_aPagar()),
          ritmoDoMesProvider.overrideWithValue(const [
            RitmoDoEnvelope(
              categoria: 'Lazer',
              gasto: 280,
              limite: 400,
              consumido: .7,
              previsto: 700,
              situacao: SituacaoRitmo.acelerado,
            ),
          ]),
          fluxoDeCaixaProvider.overrideWithValue(fluxoComFalta),
          coberturaDaReservaProvider.overrideWithValue(
            const CoberturaDaReserva(reserva: 9000, gastoMensal: 3000, alvoMeses: 6),
          ),
        ],
      ),
    );

    expect(find.text('Plano do mês'), findsOneWidget);
    expect(find.textContaining('Guardar R\$ 1.200,00'), findsOneWidget);
    expect(find.text('Ritmo do mês'), findsOneWidget);
    expect(find.textContaining('Lazer: já usou 70% do limite'), findsOneWidget);
    expect(find.text('Fluxo de caixa'), findsOneWidget);
    expect(find.text('Reserva de emergência'), findsOneWidget);
    expect(find.textContaining('cobre 3,0 meses'), findsOneWidget);
    expect(find.text('Simular compra parcelada'), findsOneWidget);
  });

  testWidgets('sem salário cadastrado o plano pede a receita', (tester) async {
    await tester.pumpWidget(_app(const PlanoDoMesScreen(), overrides: [planoDoMesProvider.overrideWithValue(null)]));

    expect(find.textContaining('Cadastre seu salário em Receitas'), findsOneWidget);
    expect(find.text('Aplicar ao orçamento'), findsNothing);
  });

  testWidgets('Aplicar ao orçamento define um limite por categoria depois de confirmar', (tester) async {
    final repo = _FakeOrcamentoRepository();
    await tester.pumpWidget(
      _app(
        const PlanoDoMesScreen(),
        overrides: [
          planoDoMesProvider.overrideWithValue(_plano()),
          definirLimiteOrcamentoUseCaseProvider.overrideWithValue(DefinirLimiteOrcamentoUseCase(repo)),
        ],
      ),
    );

    expect(find.text('Moradia'), findsOneWidget);
    expect(find.text('Mercado'), findsOneWidget);

    await tester.tap(find.text('Aplicar ao orçamento'));
    await tester.pumpAndSettle();
    expect(repo.definidos, isEmpty, reason: 'nada é gravado antes de confirmar');

    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(repo.definidos, {'Moradia': 2000, 'Mercado': 800, 'Lazer': 600});
    expect(find.text('Orçamento atualizado com o plano.'), findsOneWidget);
  });

  testWidgets('o fluxo de caixa mostra o saldo de hoje e avisa quando nada está previsto', (tester) async {
    final fluxo = projetarFluxoDeCaixa(
      saldoInicial: 100,
      hoje: DateTime(2026, 11, 12),
      rendas: const [],
      faturas: const [],
      contas: const [],
    );
    await tester.pumpWidget(_app(const FluxoDeCaixaScreen(), overrides: [fluxoDeCaixaProvider.overrideWithValue(fluxo)]));

    expect(find.text('Saldo na conta hoje'), findsOneWidget);
    expect(find.textContaining('Nada previsto'), findsOneWidget);
  });

  testWidgets('o simulador mostra a parcela e o efeito mês a mês', (tester) async {
    const nubank = Cartao(id: 'nu', nome: 'Nubank', diaFechamento: 25, diaVencimento: 5, limite: 4500);
    await tester.pumpWidget(
      _app(
        const SimuladorParcelamentoScreen(),
        overrides: [
          cartoesProvider.overrideWith((ref) async => [nubank]),
          proximasFaturasProvider.overrideWithValue(const <MesDeFaturas>[]),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Digite o valor'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '600');
    await tester.pumpAndSettle();

    expect(find.text('Cada parcela'), findsOneWidget);
    expect(find.text('R\$ 100,00'), findsWidgets, reason: '600 em 6x');
  });

  testWidgets('o simulador pede um cartão quando não há nenhum', (tester) async {
    await tester.pumpWidget(
      _app(const SimuladorParcelamentoScreen(), overrides: [cartoesProvider.overrideWith((ref) async => const <Cartao>[])]),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Cadastre um cartão'), findsOneWidget);
  });
}
