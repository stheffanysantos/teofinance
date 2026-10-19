import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/core/providers/discreet_mode_provider.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/reconciliation/domain/entities/extrato_linha.dart';
import 'package:teofinance/features/reconciliation/domain/entities/reconciliation_match.dart';
import 'package:teofinance/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:teofinance/features/reconciliation/presentation/providers/reconciliation_providers.dart';
import 'package:teofinance/features/reconciliation/presentation/screens/reconciliation_screen.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

class _FakeUser implements User {
  @override
  String get uid => 'u1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuth implements FirebaseAuth {
  @override
  User? get currentUser => _FakeUser();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ModoFixo extends ModoDiscretoNotifier {
  @override
  bool build() => false;
}

class _FakeRepository implements ReconciliationRepository {
  _FakeRepository(this.resposta);

  final Future<Either<Failure, ReconciliationResultado>> Function() resposta;

  @override
  Future<Either<Failure, ReconciliationResultado>> fazerMatching({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) =>
      resposta();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _dia = DateTime(2026, 10, 10);

Transacao _t(String id, String descricao, double valor) =>
    Transacao(id: id, descricao: descricao, categoria: 'c', valor: valor, data: _dia);

ExtratoLinha _l(String id, String descricao, double valor) => ExtratoLinha(
      id: id,
      importId: 'imp',
      descricao: descricao,
      valor: valor,
      data: _dia,
      tipo: 'D',
      nomeBancoOriginal: descricao,
    );

ReconciliationMatch _m(String linhaId, String? transacaoId, String status) => ReconciliationMatch(
      id: 'm-$linhaId',
      transacaoId: transacaoId,
      linhaExtratoId: linhaId,
      dataReconciliacao: _dia,
      status: status,
      confidence: status == 'orphan' ? 0 : 1,
    );

Widget _app(_FakeRepository repo) => ProviderScope(
      overrides: [
        reconciliationRepositoryProvider.overrideWithValue(repo),
        firebaseAuthProvider.overrideWithValue(_FakeAuth()),
        modoDiscretoProvider.overrideWith(_ModoFixo.new),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: const ReconciliationScreen()),
    );

void main() {
  testWidgets('mostra loading enquanto o matching não termina', (tester) async {
    final completer = Completer<Either<Failure, ReconciliationResultado>>();

    await tester.pumpWidget(_app(_FakeRepository(() => completer.future)));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra o erro e permite tentar de novo', (tester) async {
    await tester.pumpWidget(_app(_FakeRepository(() async => const Left(ServerFailure('falhou feio')))));
    await tester.pumpAndSettle();

    expect(find.text('falhou feio'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('sem linhas no mês mostra o estado vazio', (tester) async {
    await tester.pumpWidget(_app(_FakeRepository(
      () async => const Right(ReconciliationResultado(matches: [], linhas: {}, transacoes: {})),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Nada para reconciliar neste mês'), findsOneWidget);
  });

  testWidgets('com dados mostra relatório, seções e transação fora do extrato', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(_FakeRepository(
      () async => Right(ReconciliationResultado(
        matches: [_m('l1', 't1', 'auto_matched'), _m('l2', null, 'orphan')],
        linhas: {'l1': _l('l1', 'Café banco', 50), 'l2': _l('l2', 'Desconhecida', 80)},
        transacoes: {'t1': _t('t1', 'Café', -50), 't2': _t('t2', 'Esquecida', -10)},
      )),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Relatório do período'), findsOneWidget);
    expect(find.text('Combinados automaticamente (1)'), findsOneWidget);
    expect(find.text('No extrato, sem lançamento (1)'), findsOneWidget);
    expect(find.text('Registradas, mas fora do extrato (1)'), findsOneWidget);
    expect(find.text('Esquecida'), findsOneWidget);
  });
}
