import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/cartao/domain/entities/cartao.dart';
import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/cartao/presentation/providers/cartao_providers.dart';
import 'package:teofinance/features/cartao/presentation/widgets/proximas_faturas_secao.dart';

const _nubank = Cartao(id: 'nu', nome: 'Nubank', diaFechamento: 25, diaVencimento: 5);

Widget _app(List<MesDeFaturas> meses) => ProviderScope(
      overrides: [proximasFaturasProvider.overrideWithValue(meses)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: SingleChildScrollView(child: ProximasFaturasSecao())),
      ),
    );

MesDeFaturas _mes(int ano, int mes, double total, {double? minhaParte}) => MesDeFaturas(
      ano: ano,
      mes: mes,
      faturas: [
        FaturaDoCartaoNoMes(
          cartao: _nubank,
          total: total,
          minhaParte: minhaParte ?? total,
          vencimento: DateTime(ano, mes, 5),
          vencida: false,
        ),
      ],
    );

void main() {
  testWidgets('sem faturas em aberto a seção não aparece', (tester) async {
    await tester.pumpWidget(_app(const []));

    expect(find.text('Próximos meses'), findsNothing);
  });

  testWidgets('mostra um item por mês, com o total, e abre o detalhe por cartão', (tester) async {
    await tester.pumpWidget(_app([_mes(2026, 12, 893.5), _mes(2027, 1, 250, minhaParte: 125)]));

    expect(find.text('Próximos meses'), findsOneWidget);
    expect(find.text('Dezembro de 2026'), findsOneWidget);
    expect(find.text('Janeiro de 2027'), findsOneWidget);
    expect(find.text('R\$ 893,50'), findsOneWidget);
    expect(find.text('sua parte R\$ 125,00'), findsOneWidget, reason: 'só o mês com divisão mostra a parte do usuário');
    expect(find.text('Nubank'), findsNothing, reason: 'o detalhe por cartão fica fechado');

    await tester.tap(find.text('Janeiro de 2027'));
    await tester.pumpAndSettle();

    expect(find.text('Nubank'), findsOneWidget);
  });

  testWidgets('o gráfico mostra no máximo 6 meses, e a lista todos', (tester) async {
    final meses = [for (var i = 1; i <= 8; i++) _mes(2027, i, 100.0 * i)];
    await tester.pumpWidget(_app(meses));

    // Cada mês aparece no selo da lista; os 6 primeiros aparecem também no gráfico.
    expect(find.text('Jan'), findsNWidgets(2));
    expect(find.text('Jun'), findsNWidgets(2));
    expect(find.text('Jul'), findsOneWidget, reason: 'o gráfico para em 6 meses, só a lista tem Jul');
    expect(find.text('Agosto de 2027'), findsOneWidget, reason: 'a lista tem os 8 meses');
  });
}
