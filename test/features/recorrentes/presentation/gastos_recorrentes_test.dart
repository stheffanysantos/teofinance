import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/providers/discreet_mode_provider.dart';
import 'package:teofinance/core/theme/app_colors.dart';
import 'package:teofinance/features/recorrentes/domain/entities/gasto_recorrente.dart';
import 'package:teofinance/features/recorrentes/domain/usecases/listar_gastos_recorrentes_usecase.dart';
import 'package:teofinance/features/recorrentes/presentation/providers/recorrentes_providers.dart';
import 'package:teofinance/features/recorrentes/presentation/screens/gastos_recorrentes_screen.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';

class _ModoFixo extends ModoDiscretoNotifier {
  _ModoFixo(this._valor);
  final bool _valor;

  @override
  bool build() => _valor;
}

class _Transacoes implements TransacaoRepository {
  _Transacoes(this.dados);
  final List<Transacao> dados;

  @override
  Stream<List<Transacao>> observarTodas() => Stream.value(dados);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TransacoesQuebrado implements TransacaoRepository {
  @override
  Stream<List<Transacao>> observarTodas() => Stream.error(StateError('quebrou'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

GastoRecorrente _gasto({
  String descricao = 'NETFLIX',
  double ultimo = 39.9,
  double tipico = 39.9,
  CadenciaGasto cadencia = CadenciaGasto.mensal,
  RegularidadeGasto regularidade = RegularidadeGasto.fixo,
  bool ativa = true,
  double? variacao,
}) =>
    GastoRecorrente(
      chave: descricao.toLowerCase(),
      descricao: descricao,
      cadencia: cadencia,
      regularidade: regularidade,
      valorTipico: tipico,
      ultimoValor: ultimo,
      ultimaData: DateTime(2026, 10, 5),
      proximaData: DateTime(2026, 11, 5),
      ocorrencias: 4,
      ativa: ativa,
      variacaoDoUltimo: variacao,
    );

Widget _app(AsyncValue<List<GastoRecorrente>> gastos, {bool discreto = false}) => ProviderScope(
      overrides: [
        gastosRecorrentesProvider.overrideWith((ref) async {
          if (gastos.hasError) throw gastos.error!;
          return gastos.requireValue;
        }),
        modoDiscretoProvider.overrideWith(() => _ModoFixo(discreto)),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [AppSurfaceTokens.light]),
        home: const GastosRecorrentesScreen(),
      ),
    );

Transacao _t(String descricao, double valor, DateTime data) =>
    Transacao(id: '$descricao$data', descricao: descricao, categoria: 'x', valor: valor, data: data);

void main() {
  group('GastosRecorrentesScreen', () {
    testWidgets('sem nada recorrente explica o que é preciso para detectar', (tester) async {
      await tester.pumpWidget(_app(const AsyncValue.data([])));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum gasto recorrente encontrado'), findsOneWidget);
      expect(find.textContaining('pelo menos 3 cobranças'), findsOneWidget);
    });

    testWidgets('erro mostra a mensagem', (tester) async {
      await tester.pumpWidget(_app(AsyncValue.error('x', StackTrace.empty)));
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível analisar seus gastos agora.'), findsOneWidget);
    });

    testWidgets('mostra o peso mensal só dos gastos ativos e a contagem', (tester) async {
      await tester.pumpWidget(_app(AsyncValue.data([
        _gasto(descricao: 'NETFLIX', ultimo: 40, tipico: 40),
        _gasto(descricao: 'ACADEMIA', ultimo: 100, tipico: 100),
        _gasto(descricao: 'REVISTA', ultimo: 500, tipico: 500, ativa: false),
      ])));
      await tester.pumpAndSettle();

      expect(find.text('R\$ 140,00'), findsOneWidget); // 40 + 100; a cancelada não pesa
      expect(find.textContaining('2 gastos ativos'), findsOneWidget);
    });

    testWidgets('um único gasto usa o singular', (tester) async {
      await tester.pumpWidget(_app(AsyncValue.data([_gasto()])));
      await tester.pumpAndSettle();

      expect(find.textContaining('1 gasto ativo'), findsOneWidget);
    });

    testWidgets('cartão mostra cadência, regularidade e a próxima cobrança estimada', (tester) async {
      await tester.pumpWidget(_app(AsyncValue.data([_gasto()])));
      await tester.pumpAndSettle();

      expect(find.text('Mensal'), findsOneWidget);
      expect(find.text('Valor fixo'), findsOneWidget);
      expect(find.textContaining('próxima por volta de 05/11/2026'), findsOneWidget);
    });

    testWidgets('reajuste para cima e para baixo aparecem com a porcentagem', (tester) async {
      await tester.pumpWidget(_app(AsyncValue.data([
        _gasto(descricao: 'NETFLIX', ultimo: 44.9, variacao: 0.125),
        _gasto(descricao: 'PLANO', ultimo: 80, tipico: 100, variacao: -0.2),
      ])));
      await tester.pumpAndSettle();

      expect(find.text('Subiu 13%'), findsOneWidget);
      expect(find.text('Caiu 20%'), findsOneWidget);
    });

    testWidgets('gasto sem reajuste não mostra selo de variação', (tester) async {
      await tester.pumpWidget(_app(AsyncValue.data([_gasto()])));
      await tester.pumpAndSettle();

      expect(find.textContaining('Subiu'), findsNothing);
      expect(find.textContaining('Caiu'), findsNothing);
    });

    testWidgets('cancelados ficam numa seção própria, com aviso', (tester) async {
      await tester.pumpWidget(_app(AsyncValue.data([
        _gasto(descricao: 'NETFLIX'),
        _gasto(descricao: 'REVISTA', ativa: false),
      ])));
      await tester.pumpAndSettle();

      expect(find.text('Provavelmente cancelados (1)'), findsOneWidget);
      expect(find.textContaining('Confira se foram cancelados'), findsOneWidget);
      expect(find.textContaining('Última cobrança em 05/10/2026'), findsOneWidget);
    });

    testWidgets('sem cancelados a seção nem aparece', (tester) async {
      await tester.pumpWidget(_app(AsyncValue.data([_gasto()])));
      await tester.pumpAndSettle();

      expect(find.textContaining('Provavelmente cancelados'), findsNothing);
    });

    testWidgets('gasto ativo oferece criar conta a pagar já preenchida', (tester) async {
      await tester.pumpWidget(_app(AsyncValue.data([_gasto(descricao: 'NETFLIX', tipico: 39.9)])));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar conta a pagar'));
      await tester.pumpAndSettle();

      expect(find.text('Nova conta'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'NETFLIX'), findsOneWidget);
      expect(find.widgetWithText(TextField, '39,90'), findsOneWidget);
      expect(find.text('05/11/2026'), findsOneWidget); // a próxima cobrança estimada
      expect(find.text('Todo mês'), findsOneWidget);
    });

    testWidgets('gasto provavelmente cancelado não oferece criar conta', (tester) async {
      await tester.pumpWidget(_app(AsyncValue.data([_gasto(ativa: false)])));
      await tester.pumpAndSettle();

      expect(find.text('Criar conta a pagar'), findsNothing);
    });

    testWidgets('Modo Discreto esconde os valores', (tester) async {
      await tester.pumpWidget(_app(AsyncValue.data([_gasto(ultimo: 39.9)]), discreto: true));
      await tester.pumpAndSettle();

      expect(find.text('R\$ 39,90'), findsNothing);
      expect(find.text(kMascaraValor), findsWidgets);
    });
  });

  group('ListarGastosRecorrentesUseCase', () {
    test('detecta sobre o histórico lido do repository', () async {
      final usecase = ListarGastosRecorrentesUseCase(
        _Transacoes([
          _t('NETFLIX', -40, DateTime(2026, 8, 5)),
          _t('NETFLIX', -40, DateTime(2026, 9, 5)),
          _t('NETFLIX', -40, DateTime(2026, 10, 5)),
        ]),
        agora: () => DateTime(2026, 10, 19),
      );

      final r = (await usecase()).getOrElse((f) => throw StateError(f.message));

      expect(r.single.chave, 'netflix');
    });

    test('erro ao ler vira falha, nunca exceção', () async {
      final r = await ListarGastosRecorrentesUseCase(_TransacoesQuebrado())();

      expect(r.isLeft(), isTrue);
    });
  });
}
