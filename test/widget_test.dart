import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:teofinance/features/sync/presentation/providers/sync_providers.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/auth/domain/entities/usuario.dart';
import 'package:teofinance/features/auth/domain/repositories/auth_repository.dart';
import 'package:teofinance/features/auth/presentation/providers/auth_providers.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';
import 'package:teofinance/main.dart';

/// Usuário logado fixo, sem biometria habilitada — evita qualquer chamada
/// real ao Firebase/local_auth nos testes de widget.
class FakeAuthRepository implements AuthRepository {
  static const _usuario = Usuario(uid: 'test-uid', email: 'marina@teofinance.app');

  @override
  Usuario? get usuarioAtual => _usuario;

  @override
  Stream<Usuario?> watchUsuarioAtual() => Stream.value(_usuario);

  @override
  Future<Either<Failure, Usuario>> login({required String email, required String senha}) async =>
      const Right(_usuario);

  @override
  Future<Either<Failure, Usuario>> cadastrar({required String email, required String senha}) async =>
      const Right(_usuario);

  @override
  Future<Either<Failure, Unit>> logout() async => const Right(unit);

  @override
  Future<bool> biometriaDisponivel() async => false;

  @override
  Future<bool> biometriaHabilitada() async => false;

  @override
  Future<Either<Failure, Unit>> definirBiometriaHabilitada(bool habilitada) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> autenticarComBiometria() async => const Right(unit);
}

/// Transações em memória — evita depender do drift/sqlite3 nativo nos
/// testes de widget.
class FakeTransacaoRepository implements TransacaoRepository {
  FakeTransacaoRepository([List<Transacao>? iniciais]) : _itens = iniciais ?? [];

  final List<Transacao> _itens;
  final _controller = StreamController<List<Transacao>>.broadcast();

  void _emitir() => _controller.add(List.unmodifiable(_itens));

  @override
  Stream<List<Transacao>> observarTodas() async* {
    // Emite o snapshot atual imediatamente, depois segue com as atualizações
    // — evita depender da entrega assíncrona de um StreamController.broadcast
    // recém-escutado, que pumpAndSettle() nem sempre captura a tempo.
    yield List.unmodifiable(_itens);
    yield* _controller.stream;
  }

  @override
  Future<Either<Failure, Transacao>> criar({
    required String descricao,
    required double valor,
    required DateTime data,
    String categoria = '',
  }) async {
    final transacao = Transacao(
      id: 'fake-${_itens.length}',
      descricao: descricao,
      categoria: categoria,
      valor: valor,
      data: data,
    );
    _itens.insert(0, transacao);
    _emitir();
    return Right(transacao);
  }

  @override
  Future<Either<Failure, Unit>> categorizar({required String id, required String categoria}) async {
    final indice = _itens.indexWhere((t) => t.id == id);
    if (indice != -1) {
      final anterior = _itens[indice];
      _itens[indice] = Transacao(
        id: anterior.id,
        descricao: anterior.descricao,
        categoria: categoria,
        valor: anterior.valor,
        data: anterior.data,
      );
      _emitir();
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> excluir(String id) async {
    _itens.removeWhere((t) => t.id == id);
    _emitir();
    return const Right(unit);
  }

  @override
  Future<List<Transacao>> listarPendentesDeSincronizacao() async => [];

  @override
  Future<List<Transacao>> listarPendentesDeExclusao() async => [];

  @override
  Future<void> confirmarExclusao(String id) async {}

  @override
  Future<void> confirmarSincronizacao({required String id, required String remoteId}) async {}

  @override
  Future<void> aplicarRemoto({
    required String remoteId,
    required String descricao,
    required String categoria,
    required double valor,
    required DateTime data,
    required bool precisaCategoria,
  }) async {}
}

ProviderScope _pumpApp({TransacaoRepository? transacaoRepository}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      syncEngineProvider.overrideWithValue(null),
      transacaoRepositoryProvider.overrideWithValue(
        transacaoRepository ?? FakeTransacaoRepository(),
      ),
    ],
    child: const TeoFinanceApp(),
  );
}

void main() {
  testWidgets('Dashboard abre como tela inicial e navega até o Perfil', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_pumpApp());
    await tester.pumpAndSettle();

    expect(find.text('Saldo total'), findsOneWidget);
    expect(find.text('Últimas transações'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('marina@teofinance.app'), findsOneWidget);
    expect(find.text('742'), findsOneWidget);

    await tester.tap(find.text('Escuro'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('marina@teofinance.app'), findsOneWidget);
  });

  testWidgets('Transações mostra os grupos por data e permite categorizar', (
    WidgetTester tester,
  ) async {
    final repo = FakeTransacaoRepository([
      Transacao(
        id: 't1',
        descricao: 'PIX recebido',
        categoria: '',
        valor: -72,
        data: DateTime.now(),
      ),
    ]);
    await tester.pumpWidget(_pumpApp(transacaoRepository: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contas'));
    await tester.pumpAndSettle();

    expect(find.text('Transações'), findsOneWidget);
    expect(find.text('Sem categoria'), findsOneWidget);

    await tester.tap(find.text('Categorizar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mercado').last);
    await tester.pumpAndSettle();

    expect(find.text('Sem categoria'), findsNothing);
  });

  testWidgets('Chat IA responde a um chip de sugestão', (WidgetTester tester) async {
    await tester.pumpWidget(_pumpApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('IA'));
    await tester.pumpAndSettle();

    expect(find.text('Modelo local · funciona offline'), findsOneWidget);

    await tester.tap(find.text('Resumo do mês'));
    await tester.pumpAndSettle();

    expect(find.textContaining('72% do orçamento'), findsOneWidget);
  });

  testWidgets('Trilha abre a lição atual e o quiz responde certo/errado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_pumpApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trilha'));
    await tester.pumpAndSettle();

    expect(find.text('Primeiros investimentos'), findsOneWidget);
    expect(find.text('Juros compostos'), findsWidgets);

    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(find.text('O que é o CDI?'), findsOneWidget);

    await tester.tap(find.text('Taxa de referência baseada nos empréstimos entre bancos'));
    await tester.tap(find.text('Verificar'));
    await tester.pumpAndSettle();

    expect(find.text('Correto!'), findsOneWidget);
  });

  testWidgets('Conectar conta abre a partir de Transações e alterna as opções', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_pumpApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contas'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(find.text('Traga seus dados'), findsOneWidget);
    expect(find.text('Escolher meu banco'), findsOneWidget);

    await tester.tap(find.text('Importar arquivo CSV/OFX'));
    await tester.pumpAndSettle();

    expect(find.text('Selecionar arquivo'), findsOneWidget);
  });

  testWidgets('Orçamento abre a partir do Dashboard e mostra os envelopes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_pumpApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Despesas'));
    await tester.tap(find.text('Despesas'));
    await tester.pumpAndSettle();

    expect(find.text('Orçamento'), findsOneWidget);
    expect(find.text('Alimentação'), findsOneWidget);
  });

  testWidgets('Metas abre a partir do Dashboard e mostra o estado vazio sem metas cadastradas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_pumpApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Metas ativas'));
    await tester.tap(find.text('Metas ativas'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhuma meta cadastrada ainda.'), findsOneWidget);
  });

  testWidgets('Carteira simulada abre a partir da Trilha e alterna pizza/barras', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_pumpApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trilha'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.pie_chart_outline));
    await tester.pumpAndSettle();

    expect(find.text('Carteira simulada'), findsOneWidget);

    await tester.tap(find.text('Barras'));
    await tester.pumpAndSettle();

    expect(find.text('Desempenho · 30 dias'), findsOneWidget);
  });
}
