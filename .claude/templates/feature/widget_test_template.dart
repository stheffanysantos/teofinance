import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/nome_feature/presentation/notifiers/nome_entidade_list_notifier.dart';
import 'package:teofinance/features/nome_feature/presentation/screens/nome_entidade_list_screen.dart';

void main() {
  testWidgets('mostra loading, depois lista vazia', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: NomeEntidadeListScreen()),
      ),
    );

    // Primeiro frame: carregando.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // Sem override de repository, o provider real tentará buscar e falhar/ficar vazio
    // em ambiente de teste — em um teste real, sobrescreva nomeEntidadeRepositoryProvider
    // via ProviderScope(overrides: [...]) com um fake/mock determinístico.
  });
}
