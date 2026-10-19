import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/providers/discreet_mode_provider.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/presentation/providers/budget_providers.dart';
import 'package:teofinance/features/budget/presentation/screens/budget_screen.dart';

class _ModoFixo extends ModoDiscretoNotifier {
  @override
  bool build() => false;
}

Widget _app(AsyncValue<ResumoOrcamento> resumo) => ProviderScope(
      overrides: [
        resumoOrcamentoProvider.overrideWithValue(resumo),
        modoDiscretoProvider.overrideWith(_ModoFixo.new),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: const BudgetScreen()),
    );

void main() {
  testWidgets('carregando mostra o indicador', (tester) async {
    await tester.pumpWidget(_app(const AsyncValue.loading()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('erro mostra a mensagem', (tester) async {
    await tester.pumpWidget(_app(AsyncValue.error('x', StackTrace.empty)));

    expect(find.text('Não foi possível carregar o orçamento.'), findsOneWidget);
  });

  testWidgets('sem limites mostra o estado vazio com o convite para criar', (tester) async {
    await tester.pumpWidget(_app(const AsyncValue.data(ResumoOrcamento([]))));

    expect(find.text('Nenhum limite definido'), findsOneWidget);
    expect(find.text('Definir primeiro limite'), findsOneWidget);
  });

  testWidgets('com limites mostra cada envelope e o status de estouro', (tester) async {
    const mercado = Orcamento(id: 'o1', categoria: 'Mercado', limite: 500);
    const lazer = Orcamento(id: 'o2', categoria: 'Lazer', limite: 200);

    await tester.pumpWidget(_app(const AsyncValue.data(ResumoOrcamento([
      EnvelopeOrcamento(orcamento: lazer, gasto: 50),
      EnvelopeOrcamento(orcamento: mercado, gasto: 560),
    ]))));

    expect(find.text('Mercado'), findsOneWidget);
    expect(find.text('Lazer'), findsOneWidget);
    expect(find.text('Estourou em R\$ 60'), findsOneWidget);
    expect(find.text('Dentro do orçamento · restam R\$ 150'), findsOneWidget);
  });

  testWidgets('tocar no envelope abre a edição com a opção de excluir', (tester) async {
    const mercado = Orcamento(id: 'o1', categoria: 'Mercado', limite: 500);

    await tester.pumpWidget(_app(const AsyncValue.data(ResumoOrcamento([
      EnvelopeOrcamento(orcamento: mercado, gasto: 100),
    ]))));
    await tester.tap(find.text('Mercado'));
    await tester.pumpAndSettle();

    expect(find.text('Editar limite'), findsOneWidget);
    expect(find.text('Excluir limite'), findsOneWidget);
  });
}
