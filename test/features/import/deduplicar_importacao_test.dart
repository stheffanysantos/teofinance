import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/core/providers/discreet_mode_provider.dart';
import 'package:teofinance/core/theme/app_colors.dart';
import 'package:teofinance/features/import/domain/usecases/detectar_duplicatas_usecase.dart';
import 'package:teofinance/features/import/presentation/providers/import_flow_notifier.dart';
import 'package:teofinance/features/import/presentation/providers/import_flow_state.dart';
import 'package:teofinance/features/import/presentation/screens/import_screen.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';

class _ModoFixo extends ModoDiscretoNotifier {
  @override
  bool build() => false;
}

Uint8List _ofx(List<(String data, String valor, String memo)> linhas) {
  final corpo = linhas
      .map((l) => '<STMTTRN><DTPOSTED>${l.$1}<TRNAMT>${l.$2}<MEMO>${l.$3}</STMTTRN>')
      .join('\n');
  return Uint8List.fromList(utf8.encode('OFXHEADER:100\n<OFX><FI><ORG>Banco Exemplo</FI><BANKTRANLIST>$corpo</BANKTRANLIST></OFX>'));
}

final _mercado = ('20261005', '-52.30', 'MERCADO');
final _salario = ('20261010', '3500.00', 'SALARIO');
final _padaria = ('20261012', '-18.00', 'PADARIA');

/// O banco em memória faz I/O real, que o relógio falso do `testWidgets` não
/// avança: dá um respiro de tempo real e só então deixa a UI assentar.
Future<void> _assentar(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      modoDiscretoProvider.overrideWith(_ModoFixo.new),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  ImportFlowNotifier notifier() => container.read(importFlowProvider.notifier);
  ImportFlowState estado() => container.read(importFlowProvider);

  Future<void> abrir(Uint8List bytes) async {
    notifier().reiniciar();
    await notifier().analisarArquivo(bytes: bytes, nomeArquivo: 'extrato.ofx');
  }

  Future<int> totalTransacoes() async => (await db.select(db.transactionsTable).get()).length;
  Future<int> totalLinhasExtrato() async => (await db.select(db.extratoLinhasTable).get()).length;

  group('importar como transações', () {
    test('o mesmo arquivo importado de novo é todo apontado como duplicata', () async {
      final arquivo = _ofx([_mercado, _salario]);
      await abrir(arquivo);
      await notifier().confirmarImportacao();
      expect(await totalTransacoes(), 2);

      await abrir(arquivo);

      expect(await notifier().contarDuplicadas(DestinoImportacao.transacoes), 2);
    });

    test('"só as novas" não duplica nada ao reimportar o mesmo arquivo', () async {
      final arquivo = _ofx([_mercado, _salario]);
      await abrir(arquivo);
      await notifier().confirmarImportacao();

      await abrir(arquivo);
      await notifier().confirmarImportacao(pularDuplicadas: true);

      expect(await totalTransacoes(), 2);
      expect(estado().transacoes, isEmpty);
      expect(estado().etapa, ImportEtapa.concluido);
    });

    test('"importar todas" respeita a escolha do usuário e duplica', () async {
      final arquivo = _ofx([_mercado, _salario]);
      await abrir(arquivo);
      await notifier().confirmarImportacao();

      await abrir(arquivo);
      await notifier().confirmarImportacao();

      expect(await totalTransacoes(), 4);
    });

    test('arquivo com parte nova importa só a parte nova', () async {
      await abrir(_ofx([_mercado, _salario]));
      await notifier().confirmarImportacao();

      await abrir(_ofx([_mercado, _salario, _padaria]));
      expect(await notifier().contarDuplicadas(DestinoImportacao.transacoes), 2);
      await notifier().confirmarImportacao(pularDuplicadas: true);

      expect(await totalTransacoes(), 3);
      expect(estado().transacoes.single.descricao, 'PADARIA');
    });

    test('compras repetidas de verdade não são descartadas', () async {
      await TransacaoLocalDataSource(db).criar(
        descricao: 'CAFE',
        valor: -8,
        data: DateTime(2026, 10, 5),
        categoria: '',
      );
      final cafe = ('20261005', '-8.00', 'CAFE');

      await abrir(_ofx([cafe, cafe]));
      expect(await notifier().contarDuplicadas(DestinoImportacao.transacoes), 1);
      await notifier().confirmarImportacao(pularDuplicadas: true);

      expect(await totalTransacoes(), 2); // 1 existente + 1 compra nova
    });

    test('sem nada repetido, contarDuplicadas devolve zero', () async {
      await abrir(_ofx([_mercado]));

      expect(await notifier().contarDuplicadas(DestinoImportacao.transacoes), 0);
    });
  });

  group('importar para reconciliação', () {
    test('reimportar o mesmo extrato aponta as linhas repetidas e "só as novas" não duplica', () async {
      final arquivo = _ofx([_mercado, _salario]);
      await abrir(arquivo);
      await notifier().confirmarParaReconciliacao();
      expect(await totalLinhasExtrato(), 2);

      await abrir(arquivo);
      expect(await notifier().contarDuplicadas(DestinoImportacao.reconciliacao), 2);
      await notifier().confirmarParaReconciliacao(pularDuplicadas: true);

      expect(await totalLinhasExtrato(), 2);
    });

    test('uma transação igual à linha NÃO conta como duplicata: casar com ela é o objetivo', () async {
      await TransacaoLocalDataSource(db).criar(
        descricao: 'MERCADO',
        valor: -52.30,
        data: DateTime(2026, 10, 5),
        categoria: 'Mercado',
      );
      await abrir(_ofx([_mercado]));

      expect(await notifier().contarDuplicadas(DestinoImportacao.reconciliacao), 0);
      expect(await notifier().contarDuplicadas(DestinoImportacao.transacoes), 1);
    });

    test('linhas de extrato já importadas não contam como duplicata de transação', () async {
      await abrir(_ofx([_mercado]));
      await notifier().confirmarParaReconciliacao();

      await abrir(_ofx([_mercado]));

      expect(await notifier().contarDuplicadas(DestinoImportacao.transacoes), 0);
    });
  });

  group('tela de revisão', () {
    Widget app() => UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            // Só os tokens: `AppTheme.light()` carrega Manrope pelo google_fonts, que tentaria
            // baixar a fonte da rede durante o tempo real de `runAsync`.
            theme: ThemeData(extensions: [AppSurfaceTokens.light]),
            home: const ImportScreen(),
          ),
        );

    testWidgets('sem repetidas, confirma direto, sem perguntar', (tester) async {
      await abrir(_ofx([_mercado, _salario]));
      await tester.pumpWidget(app());

      await tester.tap(find.text('Confirmar importação'));
      await _assentar(tester);

      expect(find.text('Parte do arquivo já foi importada'), findsNothing);
      expect(await totalTransacoes(), 2);
    });

    testWidgets('com repetidas, pergunta e "Só as novas" importa apenas o que é novo', (tester) async {
      await abrir(_ofx([_mercado, _salario]));
      await notifier().confirmarImportacao();
      await abrir(_ofx([_mercado, _salario, _padaria]));
      await tester.pumpWidget(app());

      await tester.tap(find.text('Confirmar importação'));
      await _assentar(tester);

      expect(find.text('Parte do arquivo já foi importada'), findsOneWidget);
      expect(find.textContaining('2 de 3 linhas'), findsOneWidget);
      expect(find.textContaining('Só 1 é nova'), findsOneWidget);

      await tester.tap(find.text('Só as novas'));
      await _assentar(tester);

      expect(await totalTransacoes(), 3);
    });

    testWidgets('Cancelar no diálogo não importa nada e mantém a revisão', (tester) async {
      await abrir(_ofx([_mercado]));
      await notifier().confirmarImportacao();
      await abrir(_ofx([_mercado]));
      await tester.pumpWidget(app());

      await tester.tap(find.text('Confirmar importação'));
      await _assentar(tester);
      await tester.tap(find.text('Cancelar'));
      await _assentar(tester);

      expect(await totalTransacoes(), 1);
      expect(estado().etapa, ImportEtapa.revisando);
    });

    testWidgets('quando nada é novo, o botão avisa que não importa nada', (tester) async {
      await abrir(_ofx([_mercado]));
      await notifier().confirmarImportacao();
      await abrir(_ofx([_mercado]));
      await tester.pumpWidget(app());

      await tester.tap(find.text('Confirmar importação'));
      await _assentar(tester);

      expect(find.textContaining('Nenhuma é nova.'), findsOneWidget);
      expect(find.text('Não importar'), findsOneWidget);
    });
  });
}
