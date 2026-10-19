import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/core/providers/discreet_mode_provider.dart';
import 'package:teofinance/core/theme/app_colors.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/repositories/conta_repository.dart';
import 'package:teofinance/features/contas/domain/services/resumo_contas.dart';
import 'package:teofinance/features/contas/presentation/providers/conta_providers.dart';
import 'package:teofinance/features/contas/presentation/screens/conta_form_screen.dart';
import 'package:teofinance/features/contas/presentation/screens/contas_screen.dart';
import 'package:teofinance/features/dashboard/presentation/widgets/contas_a_vencer_card.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

class _ModoFixo extends ModoDiscretoNotifier {
  @override
  bool build() => false;
}

/// Repositório de contas em memória: sem banco, sem I/O real, sem esperas.
class _FakeContas implements ContaRepository {
  final contas = <ContaAPagar>[];
  final _mudancas = StreamController<void>.broadcast();
  int _seq = 0;

  void _avisar() => _mudancas.add(null);

  List<ContaAPagar> get _ordenadas => [...contas]..sort((a, b) => a.vencimento.compareTo(b.vencimento));

  ContaAPagar semear(String nome, DateTime venc, {double valor = 100, RecorrenciaConta rec = RecorrenciaConta.nenhuma}) {
    final c = ContaAPagar(
      id: 'c${_seq++}',
      descricao: nome,
      valor: valor,
      vencimento: soDia(venc),
      diaBase: venc.day,
      categoria: 'Moradia',
      recorrencia: rec,
    );
    contas.add(c);
    return c;
  }

  @override
  Stream<List<ContaAPagar>> observarTodas() async* {
    yield _ordenadas;
    await for (final _ in _mudancas.stream) {
      yield _ordenadas;
    }
  }

  @override
  Future<Either<Failure, ContaAPagar>> criar({
    required String descricao,
    required double valor,
    required DateTime vencimento,
    String categoria = '',
    RecorrenciaConta recorrencia = RecorrenciaConta.nenhuma,
    int diasAntesLembrete = 1,
    int? diaBase,
  }) async {
    final c = ContaAPagar(
      id: 'c${_seq++}',
      descricao: descricao,
      valor: valor,
      vencimento: soDia(vencimento),
      diaBase: diaBase ?? vencimento.day,
      categoria: categoria,
      recorrencia: recorrencia,
      diasAntesLembrete: diasAntesLembrete,
    );
    contas.add(c);
    _avisar();
    return Right(c);
  }

  @override
  Future<Either<Failure, ContaAPagar>> atualizar(ContaAPagar conta) async {
    contas[contas.indexWhere((c) => c.id == conta.id)] = conta;
    _avisar();
    return Right(conta);
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async {
    contas.removeWhere((c) => c.id == id);
    _avisar();
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> marcarComoPaga({
    required String id,
    required double valorPago,
    required DateTime dataPagamento,
    String? transacaoId,
  }) async {
    final i = contas.indexWhere((c) => c.id == id);
    final c = contas[i];
    contas[i] = ContaAPagar(
      id: c.id,
      descricao: c.descricao,
      valor: c.valor,
      vencimento: c.vencimento,
      diaBase: c.diaBase,
      categoria: c.categoria,
      recorrencia: c.recorrencia,
      paga: true,
      dataPagamento: dataPagamento,
      valorPago: valorPago,
      transacaoId: transacaoId,
    );
    _avisar();
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransacoes implements TransacaoRepository {
  final criadas = <({String descricao, double valor, String categoria})>[];

  @override
  Future<Either<Failure, Transacao>> criar({
    required String descricao,
    required double valor,
    required DateTime data,
    String categoria = '',
  }) async {
    criadas.add((descricao: descricao, valor: valor, categoria: categoria));
    return Right(Transacao(id: 't${criadas.length}', descricao: descricao, categoria: categoria, valor: valor, data: data));
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async => const Right(unit);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeContas contas;
  late _FakeTransacoes transacoes;

  setUp(() {
    contas = _FakeContas();
    transacoes = _FakeTransacoes();
  });

  Widget app(Widget home) => ProviderScope(
        overrides: [
          contaRepositoryProvider.overrideWithValue(contas),
          transacaoRepositoryProvider.overrideWithValue(transacoes),
          modoDiscretoProvider.overrideWith(_ModoFixo.new),
        ],
        child: MaterialApp(theme: ThemeData(extensions: [AppSurfaceTokens.light]), home: home),
      );

  final hoje = DateTime.now();

  group('ContasScreen', () {
    testWidgets('sem contas mostra o convite para adicionar', (tester) async {
      await tester.pumpWidget(app(const ContasScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Nenhuma conta cadastrada'), findsOneWidget);
    });

    testWidgets('separa atrasadas, a vencer e pagas, com o texto de prazo', (tester) async {
      contas.semear('Luz', hoje.subtract(const Duration(days: 3)));
      contas.semear('Internet', hoje.add(const Duration(days: 5)));
      final paga = contas.semear('Água', hoje);
      await contas.marcarComoPaga(id: paga.id, valorPago: 80, dataPagamento: hoje);

      await tester.pumpWidget(app(const ContasScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Atrasadas (1)'), findsOneWidget);
      expect(find.text('A vencer (1)'), findsOneWidget);
      expect(find.text('Pagas (1)'), findsOneWidget);
      expect(find.textContaining('Atrasada há 3 dias'), findsOneWidget);
      expect(find.textContaining('em 5 dias'), findsOneWidget);
    });

    testWidgets('conta paga não oferece Pagar nem Editar', (tester) async {
      final c = contas.semear('Água', hoje);
      await contas.marcarComoPaga(id: c.id, valorPago: 80, dataPagamento: hoje);

      await tester.pumpWidget(app(const ContasScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Pagar'), findsNothing);
      expect(find.byTooltip('Editar'), findsNothing);
      expect(find.byTooltip('Excluir'), findsOneWidget);
    });

    testWidgets('pagar cria a despesa com o valor digitado e marca a conta como paga', (tester) async {
      contas.semear('Aluguel', hoje.add(const Duration(days: 2)), valor: 1500);

      await tester.pumpWidget(app(const ContasScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pagar'));
      await tester.pumpAndSettle();

      expect(find.text('Pagar Aluguel'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1480,50');
      await tester.tap(find.text('Confirmar pagamento'));
      await tester.pumpAndSettle();

      expect(transacoes.criadas.single.valor, -1480.5);
      expect(transacoes.criadas.single.descricao, 'Aluguel');
      expect(contas.contas.single.paga, isTrue);
      expect(find.text('Pagas (1)'), findsOneWidget);
    });

    testWidgets('valor pago vazio mostra erro e não cria despesa', (tester) async {
      contas.semear('Luz', hoje.add(const Duration(days: 2)));

      await tester.pumpWidget(app(const ContasScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pagar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Confirmar pagamento'));
      await tester.pumpAndSettle();

      expect(find.text('Informe o valor pago.'), findsOneWidget);
      expect(transacoes.criadas, isEmpty);
    });

    testWidgets('excluir pede confirmação; cancelar mantém, confirmar remove', (tester) async {
      contas.semear('Luz', hoje.add(const Duration(days: 2)));

      await tester.pumpWidget(app(const ContasScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Excluir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Luz'), findsOneWidget);

      await tester.tap(find.byTooltip('Excluir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir').last);
      await tester.pumpAndSettle();

      expect(find.text('Luz'), findsNothing);
      expect(contas.contas, isEmpty);
    });
  });

  group('ContaFormScreen', () {
    testWidgets('cria a conta com os dados informados', (tester) async {
      await tester.pumpWidget(app(const ContaFormScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Descrição'), 'Seguro');
      await tester.enterText(find.widgetWithText(TextField, 'Valor'), '1.234,56');
      await tester.tap(find.text('Salvar conta'));
      await tester.pumpAndSettle();

      expect(contas.contas.single.descricao, 'Seguro');
      expect(contas.contas.single.valor, 1234.56);
    });

    testWidgets('valor inválido e nome vazio mostram o erro e não gravam', (tester) async {
      await tester.pumpWidget(app(const ContaFormScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar conta'));
      await tester.pumpAndSettle();
      expect(find.text('Informe um valor válido.'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Valor'), '50');
      await tester.tap(find.text('Salvar conta'));
      await tester.pumpAndSettle();
      expect(find.text('Dê um nome à conta.'), findsOneWidget);

      expect(contas.contas, isEmpty);
    });

    testWidgets('editar preenche os campos e salva a alteração preservando o dia-base', (tester) async {
      final c = contas.semear('Luz', DateTime(2026, 11, 10), valor: 100);

      await tester.pumpWidget(app(ContaFormScreen(existente: c)));
      await tester.pumpAndSettle();
      expect(find.text('Editar conta'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Valor'), '150');
      await tester.tap(find.text('Salvar conta'));
      await tester.pumpAndSettle();

      expect(contas.contas.single.valor, 150);
      expect(contas.contas.single.diaBase, 10);
    });
  });

  group('ContasAVencerCard', () {
    ResumoContas resumo({int atrasadas = 0, int aVencer = 0}) => ResumoContas(
          atrasadas: atrasadas,
          valorAtrasadas: 100.0 * atrasadas,
          aVencerEm7Dias: aVencer,
          valorAVencerEm7Dias: 50.0 * aVencer,
          pendentesNoMes: 0,
          valorPendenteNoMes: 0,
        );

    Widget cartao(ResumoContas r, VoidCallback onTap) => ProviderScope(
          overrides: [modoDiscretoProvider.overrideWith(_ModoFixo.new)],
          child: MaterialApp(
            theme: ThemeData(extensions: [AppSurfaceTokens.light]),
            home: Scaffold(body: ContasAVencerCard(resumo: r, onTap: onTap)),
          ),
        );

    testWidgets('mostra atrasadas e a vencer com singular e plural', (tester) async {
      await tester.pumpWidget(cartao(resumo(atrasadas: 1, aVencer: 3), () {}));

      expect(find.text('1 atrasada'), findsOneWidget);
      expect(find.text('3 a vencer em 7 dias'), findsOneWidget);
      expect(find.text('R\$ 100,00'), findsOneWidget);
      expect(find.text('R\$ 150,00'), findsOneWidget);
    });

    testWidgets('sem atrasadas não mostra a linha de atrasadas; tocar chama onTap', (tester) async {
      var toques = 0;
      await tester.pumpWidget(cartao(resumo(aVencer: 2), () => toques++));

      expect(find.textContaining('atrasad'), findsNothing);
      await tester.tap(find.text('Contas a pagar'));
      expect(toques, 1);
    });
  });
}
