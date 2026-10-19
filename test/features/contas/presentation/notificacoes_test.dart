import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/core/services/notificacao_service.dart';
import 'package:teofinance/core/theme/app_colors.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/presentation/providers/conta_providers.dart';
import 'package:teofinance/features/contas/presentation/providers/lembretes_providers.dart';
import 'package:teofinance/features/contas/presentation/screens/notificacoes_screen.dart';

class _Armazenamento implements FlutterSecureStorage {
  final dados = <String, String>{};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final chave = invocation.namedArguments[#key] as String;
    if (invocation.memberName == #write) {
      dados[chave] = invocation.namedArguments[#value] as String;
      return Future<void>.value();
    }
    return Future<String?>.value(dados[chave]);
  }
}

class _FakeNotificacoes implements NotificacaoService {
  bool permissao = false;
  bool concederAoPedir = true;
  int pedidos = 0;
  int testes = 0;
  List<NotificacaoAgendada>? agendadas;
  int cancelamentos = 0;

  @override
  Future<bool> permissaoConcedida() async => permissao;

  @override
  Future<bool> pedirPermissao() async {
    pedidos++;
    if (concederAoPedir) permissao = true;
    return permissao;
  }

  @override
  Future<void> reagendarTudo(List<NotificacaoAgendada> lembretes) async => agendadas = lembretes;

  @override
  Future<void> cancelarTudo() async => cancelamentos++;

  @override
  Future<void> mostrarAgora({required String titulo, required String corpo}) async => testes++;
}

void main() {
  late _FakeNotificacoes servico;
  late _Armazenamento armazenamento;

  setUp(() {
    servico = _FakeNotificacoes();
    armazenamento = _Armazenamento();
  });

  ProviderContainer container({List<ContaAPagar> contas = const []}) {
    final c = ProviderContainer(overrides: [
      notificacaoServiceProvider.overrideWithValue(servico),
      secureStorageProvider.overrideWithValue(armazenamento),
      contasStreamProvider.overrideWith((ref) => Stream.value(contas)),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  group('configuração', () {
    test('padrão: ativa, às 9h', () {
      final c = container();

      expect(c.read(configLembretesProvider).ativo, isTrue);
      expect(c.read(configLembretesProvider).hora, 9);
    });

    test('guarda e restaura ativo e hora', () async {
      final c = container();
      await c.read(configLembretesProvider.notifier).definirAtivo(false);
      await c.read(configLembretesProvider.notifier).definirHora(18);

      final outro = container();
      outro.read(configLembretesProvider);
      await Future<void>.delayed(Duration.zero);

      expect(outro.read(configLembretesProvider).ativo, isFalse);
      expect(outro.read(configLembretesProvider).hora, 18);
    });

    test('hora fora de 0 a 23 é ignorada', () async {
      final c = container();

      await c.read(configLembretesProvider.notifier).definirHora(25);
      await c.read(configLembretesProvider.notifier).definirHora(-1);

      expect(c.read(configLembretesProvider).hora, 9);
    });

    test('valor guardado corrompido volta ao padrão', () async {
      armazenamento.dados['lembretes_hora'] = 'abc';
      final c = container();
      c.read(configLembretesProvider);
      await Future<void>.delayed(Duration.zero);

      expect(c.read(configLembretesProvider).hora, 9);
    });
  });

  group('lembretesAutomaticosProvider', () {
    final conta = ContaAPagar(
      id: 'a',
      descricao: 'Luz',
      valor: 100,
      vencimento: DateTime.now().add(const Duration(days: 10)),
      diaBase: 10,
    );

    test('agenda quando as contas chegam e há permissão', () async {
      servico.permissao = true;
      final c = container(contas: [conta]);

      c.read(lembretesAutomaticosProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(servico.agendadas, isNotEmpty);
    });

    test('sem permissão não agenda nada', () async {
      final c = container(contas: [conta]);

      c.read(lembretesAutomaticosProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(servico.agendadas, isNull);
    });

    test('desligar nas configurações cancela tudo', () async {
      servico.permissao = true;
      final c = container(contas: [conta]);
      c.read(lembretesAutomaticosProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await c.read(configLembretesProvider.notifier).definirAtivo(false);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(servico.cancelamentos, greaterThan(0));
    });
  });

  group('NotificacoesScreen', () {
    Widget app() => UncontrolledProviderScope(
          container: container(),
          child: MaterialApp(
            theme: ThemeData(extensions: [AppSurfaceTokens.light]),
            home: const NotificacoesScreen(),
          ),
        );

    testWidgets('sem permissão o interruptor aparece desligado e avisa', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isFalse);
      expect(find.text('Permissão do sistema pendente'), findsOneWidget);
    });

    testWidgets('ligar pede a permissão e, concedida, liga', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(servico.pedidos, 1);
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isTrue);
    });

    testWidgets('permissão negada mantém desligado e explica onde liberar', (tester) async {
      servico.concederAoPedir = false;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isFalse);
      expect(find.textContaining('Configurações > Apps'), findsOneWidget);
    });

    testWidgets('o botão de teste dispara a notificação quando há permissão', (tester) async {
      servico.permissao = true;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enviar notificação de teste'));
      await tester.pumpAndSettle();

      expect(servico.testes, 1);
    });

    testWidgets('o teste sem permissão pede e, se negada, não notifica', (tester) async {
      servico.concederAoPedir = false;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enviar notificação de teste'));
      await tester.pumpAndSettle();

      expect(servico.testes, 0);
      expect(find.text('Permissão de notificação negada.'), findsOneWidget);
    });
  });
}
