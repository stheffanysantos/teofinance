import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/theme/app_colors.dart';
import 'package:teofinance/features/profile/presentation/widgets/financial_score_gauge.dart';
import 'package:teofinance/features/score/domain/entities/score_financeiro.dart';
import 'package:teofinance/features/score/presentation/widgets/como_calculamos_score_sheet.dart';

Widget _app(Widget filho) => MaterialApp(
      theme: ThemeData(extensions: [AppSurfaceTokens.light]),
      home: Scaffold(body: SingleChildScrollView(child: filho)),
    );

const _componentes = [
  ComponenteScore(nome: 'Orçamento', peso: 30, fracao: 0.5, detalhe: '1 de 2 envelopes dentro do limite.'),
  ComponenteScore(nome: 'Metas', peso: 20, fracao: null, detalhe: 'Crie uma meta para medir.'),
];

ScoreFinanceiro _scoreComNota(double fracao) =>
    ScoreFinanceiro([ComponenteScore(nome: 'x', peso: 100, fracao: fracao, detalhe: '')]);

void main() {
  group('FinancialScoreGauge', () {
    testWidgets('mostra a nota calculada e a faixa, sem rótulo fixo', (tester) async {
      await tester.pumpWidget(_app(FinancialScoreGauge(score: _scoreComNota(0.742), onTap: () {})));

      expect(find.text('742'), findsOneWidget);
      expect(find.text('Bom'), findsOneWidget);
      expect(find.textContaining('pontos este mês'), findsNothing);
    });

    testWidgets('a faixa acompanha a nota', (tester) async {
      await tester.pumpWidget(_app(FinancialScoreGauge(score: _scoreComNota(0.3), onTap: () {})));

      expect(find.text('300'), findsOneWidget);
      expect(find.text('Atenção'), findsOneWidget);
      expect(find.text('Bom'), findsNothing);
    });

    testWidgets('sem dados mostra traço e orienta, nunca um número', (tester) async {
      const semDados = ScoreFinanceiro([
        ComponenteScore(nome: 'x', peso: 100, fracao: null, detalhe: ''),
      ]);
      await tester.pumpWidget(_app(FinancialScoreGauge(score: semDados, onTap: () {})));

      expect(find.text('—'), findsOneWidget);
      expect(find.textContaining('Registre transações'), findsOneWidget);
    });

    testWidgets('carregando mostra reticências e nenhuma mensagem de erro', (tester) async {
      await tester.pumpWidget(_app(FinancialScoreGauge(score: null, carregando: true, onTap: () {})));

      expect(find.text('…'), findsOneWidget);
      expect(find.textContaining('Não foi possível'), findsNothing);
    });

    testWidgets('falha no cálculo avisa em vez de mostrar uma nota', (tester) async {
      await tester.pumpWidget(_app(FinancialScoreGauge(score: null, onTap: () {})));

      expect(find.text('—'), findsOneWidget);
      expect(find.text('Não foi possível calcular agora.'), findsOneWidget);
    });

    testWidgets('tocar no medidor chama o onTap', (tester) async {
      var toques = 0;
      await tester.pumpWidget(_app(FinancialScoreGauge(score: _scoreComNota(0.5), onTap: () => toques++)));

      await tester.tap(find.text('Score financeiro'));

      expect(toques, 1);
    });
  });

  group('ComoCalculamosScoreSheet', () {
    testWidgets('lista cada componente com peso, porcentagem e detalhe', (tester) async {
      await tester.pumpWidget(_app(const ComoCalculamosScoreSheet(score: ScoreFinanceiro(_componentes))));

      expect(find.text('Como o score é calculado'), findsOneWidget);
      expect(find.text('Orçamento'), findsOneWidget);
      expect(find.text('peso 30%'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('1 de 2 envelopes dentro do limite.'), findsOneWidget);
    });

    testWidgets('componente sem dado aparece como "sem dados" e diz o que fazer', (tester) async {
      await tester.pumpWidget(_app(const ComoCalculamosScoreSheet(score: ScoreFinanceiro(_componentes))));

      expect(find.text('sem dados'), findsOneWidget);
      expect(find.text('Crie uma meta para medir.'), findsOneWidget);
    });

    testWidgets('explica que a conta é feita no aparelho e que o que falta não pesa contra', (tester) async {
      await tester.pumpWidget(_app(const ComoCalculamosScoreSheet(score: ScoreFinanceiro(_componentes))));

      expect(find.textContaining('no seu aparelho'), findsOneWidget);
      expect(find.textContaining('sem pesar contra você'), findsOneWidget);
    });

    testWidgets('sem score avisa que não foi possível calcular', (tester) async {
      await tester.pumpWidget(_app(const ComoCalculamosScoreSheet(score: null)));

      expect(find.text('Não foi possível calcular agora.'), findsOneWidget);
    });
  });
}
