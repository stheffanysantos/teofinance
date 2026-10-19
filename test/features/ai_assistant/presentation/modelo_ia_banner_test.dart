import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/ai_assistant/domain/entities/estado_modelo.dart';
import 'package:teofinance/features/ai_assistant/domain/services/gerenciador_modelo.dart';
import 'package:teofinance/features/ai_assistant/presentation/providers/ai_assistant_providers.dart';
import 'package:teofinance/features/ai_assistant/presentation/widgets/modelo_ia_banner.dart';

class _FakeGerenciador implements GerenciadorModelo {
  _FakeGerenciador(this.estado);

  final EstadoModelo estado;
  int downloads = 0;

  @override
  Stream<EstadoModelo> observarEstado() => Stream.value(estado);

  @override
  Future<void> baixar() async => downloads++;

  @override
  Future<void> remover() async {}
}

Widget _app(_FakeGerenciador gerenciador) => ProviderScope(
      overrides: [gerenciadorModeloProvider.overrideWithValue(gerenciador)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: ModeloIaBanner()),
      ),
    );

void main() {
  testWidgets('modelo não instalado convida a baixar, com o tamanho, e baixa ao tocar', (tester) async {
    final gerenciador = _FakeGerenciador(const ModeloNaoInstalado(tamanhoEmMb: 500));
    await tester.pumpWidget(_app(gerenciador));
    await tester.pumpAndSettle();

    expect(find.textContaining('≈ 500 MB'), findsOneWidget);
    expect(find.textContaining('nada seu é enviado'), findsOneWidget);

    await tester.tap(find.text('Baixar'));
    expect(gerenciador.downloads, 1);
  });

  testWidgets('baixando mostra a porcentagem e a barra, sem botão', (tester) async {
    await tester.pumpWidget(_app(_FakeGerenciador(const ModeloBaixando(0.42))));
    await tester.pumpAndSettle();

    expect(find.text('Baixando o modelo… 42%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('erro mostra o motivo e permite tentar de novo', (tester) async {
    final gerenciador = _FakeGerenciador(const ModeloComErro('sem espaço'));
    await tester.pumpWidget(_app(gerenciador));
    await tester.pumpAndSettle();

    expect(find.textContaining('sem espaço'), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));
    expect(gerenciador.downloads, 1);
  });

  for (final (nome, estado) in [
    ('pronto', const ModeloPronto()),
    ('indisponível neste build', const ModeloIndisponivel()),
  ]) {
    testWidgets('modelo $nome não mostra nenhuma faixa', (tester) async {
      await tester.pumpWidget(_app(_FakeGerenciador(estado)));
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.textContaining('modelo'), findsNothing);
    });
  }
}
