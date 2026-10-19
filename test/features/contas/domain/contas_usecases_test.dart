import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/contas/data/datasources/conta_local_datasource.dart';
import 'package:teofinance/features/contas/data/repositories/conta_repository_impl.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/usecases/criar_conta_usecase.dart';
import 'package:teofinance/features/contas/domain/usecases/editar_conta_usecase.dart';
import 'package:teofinance/features/contas/domain/usecases/excluir_conta_usecase.dart';
import 'package:teofinance/features/contas/domain/usecases/marcar_conta_como_paga_usecase.dart';
import 'package:teofinance/features/transacao/data/datasources/transacao_local_datasource.dart';
import 'package:teofinance/features/transacao/data/repositories/transacao_repository_impl.dart';

/// Repository de contas cujo `marcarComoPaga` falha: simula um erro no meio do
/// pagamento, depois que a despesa já foi criada.
class _ContaQueFalhaAoPagar extends ContaRepositoryImpl {
  _ContaQueFalhaAoPagar(super.local);

  @override
  Future<Either<Failure, Unit>> marcarComoPaga({
    required String id,
    required double valorPago,
    required DateTime dataPagamento,
    String? transacaoId,
  }) async =>
      const Left(CacheFailure('falhou'));
}

Failure _falha<T>(Either<Failure, T> r) => r.swap().getOrElse((_) => throw StateError('esperava Left'));
T _ok<T>(Either<Failure, T> r) => r.getOrElse((f) => throw StateError(f.message));

void main() {
  late AppDatabase db;
  late ContaRepositoryImpl contas;
  late TransacaoRepositoryImpl transacoes;
  late MarcarContaComoPagaUseCase marcarComoPaga;
  final agora = DateTime(2026, 11, 9, 10);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    contas = ContaRepositoryImpl(ContaLocalDataSource(db));
    transacoes = TransacaoRepositoryImpl(TransacaoLocalDataSource(db));
    marcarComoPaga = MarcarContaComoPagaUseCase(contas: contas, transacoes: transacoes, agora: () => agora);
  });

  tearDown(() => db.close());

  Future<List<ContaAPagar>> todas() => contas.observarTodas().first;
  Future<int> totalTransacoes() async => (await db.select(db.transactionsTable).get()).length;

  Future<ContaAPagar> criar({
    String descricao = 'Aluguel',
    double valor = 1500,
    DateTime? vencimento,
    RecorrenciaConta recorrencia = RecorrenciaConta.mensal,
    String categoria = 'Moradia',
  }) async {
    return _ok(await CriarContaUseCase(contas)(
      descricao: descricao,
      valor: valor,
      vencimento: vencimento ?? DateTime(2026, 11, 10),
      recorrencia: recorrencia,
      categoria: categoria,
    ));
  }

  group('CriarContaUseCase', () {
    test('cria, apara o nome e normaliza o vencimento para o dia', () async {
      final c = _ok(await CriarContaUseCase(contas)(
        descricao: '  Internet  ',
        valor: 120,
        vencimento: DateTime(2026, 11, 15, 18, 40),
      ));

      expect(c.descricao, 'Internet');
      expect(c.vencimento, DateTime(2026, 11, 15));
      expect(c.diaBase, 15);
      expect(c.paga, isFalse);
      expect(await todas(), hasLength(1));
    });

    test('dados inválidos são recusados sem gravar nada', () async {
      final usecase = CriarContaUseCase(contas);

      expect(_falha(await usecase(descricao: ' ', valor: 10, vencimento: DateTime(2026, 11, 1))), isA<ValidationFailure>());
      expect(_falha(await usecase(descricao: 'x', valor: 0, vencimento: DateTime(2026, 11, 1))), isA<ValidationFailure>());
      expect(
        _falha(await usecase(descricao: 'x', valor: 10, vencimento: DateTime(2026, 11, 1), diasAntesLembrete: 99)),
        isA<ValidationFailure>(),
      );
      expect(await todas(), isEmpty);
    });

    test('a lista sai ordenada pelo vencimento', () async {
      await criar(descricao: 'B', vencimento: DateTime(2026, 12, 1));
      await criar(descricao: 'A', vencimento: DateTime(2026, 11, 1));

      expect((await todas()).map((c) => c.descricao), ['A', 'B']);
    });
  });

  group('EditarContaUseCase', () {
    test('edita valor e descrição preservando o dia-base', () async {
      final c = await criar(vencimento: DateTime(2026, 1, 31));

      final editada = _ok(await EditarContaUseCase(contas)(c.copyWith(descricao: 'Novo nome', valor: 1600)));

      expect(editada.descricao, 'Novo nome');
      expect(editada.valor, 1600);
      expect(editada.diaBase, 31);
    });

    test('reagendar atualiza o vencimento e o dia-base', () async {
      final c = await criar(vencimento: DateTime(2026, 1, 31));

      final editada = _ok(await EditarContaUseCase(contas)(c.reagendada(DateTime(2026, 2, 10))));

      expect(editada.vencimento, DateTime(2026, 2, 10));
      expect(editada.diaBase, 10);
    });

    test('dados inválidos são recusados', () async {
      final c = await criar();

      expect(_falha(await EditarContaUseCase(contas)(c.copyWith(valor: -1))), isA<ValidationFailure>());
      expect((await todas()).single.valor, 1500);
    });

    test('conta já paga não pode ser editada', () async {
      final c = await criar(recorrencia: RecorrenciaConta.nenhuma);
      _ok(await marcarComoPaga(conta: c, valorPago: 1500));

      final paga = (await todas()).single;
      final r = await EditarContaUseCase(contas)(paga.copyWith(valor: 1));

      expect(_falha(r), isA<ValidationFailure>());
    });
  });

  group('ExcluirContaUseCase', () {
    test('exclui pelo id', () async {
      final c = await criar();

      _ok(await ExcluirContaUseCase(contas)(c.id));

      expect(await todas(), isEmpty);
    });

    test('id vazio é recusado', () async {
      expect(_falha(await ExcluirContaUseCase(contas)('')), isA<ValidationFailure>());
    });
  });

  group('MarcarContaComoPagaUseCase', () {
    test('cria a despesa, marca a conta como paga e liga as duas', () async {
      final c = await criar(recorrencia: RecorrenciaConta.nenhuma);

      _ok(await marcarComoPaga(conta: c, valorPago: 1480));

      final conta = (await todas()).single;
      expect(conta.paga, isTrue);
      expect(conta.valorPago, 1480);
      expect(conta.dataPagamento, agora);
      final despesas = await db.select(db.transactionsTable).get();
      expect(despesas, hasLength(1));
      expect(despesas.single.value, -1480);
      expect(despesas.single.name, 'Aluguel');
      expect(despesas.single.category, 'Moradia');
      expect(conta.transacaoId, despesas.single.id);
    });

    test('a categoria informada no pagamento vale mais que a da conta', () async {
      final c = await criar(recorrencia: RecorrenciaConta.nenhuma);

      _ok(await marcarComoPaga(conta: c, valorPago: 100, categoria: 'Lazer'));

      expect((await db.select(db.transactionsTable).get()).single.category, 'Lazer');
    });

    test('a data de pagamento informada é usada na despesa', () async {
      final c = await criar(recorrencia: RecorrenciaConta.nenhuma);

      _ok(await marcarComoPaga(conta: c, valorPago: 100, dataPagamento: DateTime(2026, 11, 5)));

      expect((await db.select(db.transactionsTable).get()).single.occurredAt, DateTime(2026, 11, 5));
    });

    test('valor pago zero, negativo ou NaN é recusado e nada é criado', () async {
      final c = await criar();

      expect(_falha(await marcarComoPaga(conta: c, valorPago: 0)), isA<ValidationFailure>());
      expect(_falha(await marcarComoPaga(conta: c, valorPago: -1)), isA<ValidationFailure>());
      expect(_falha(await marcarComoPaga(conta: c, valorPago: double.nan)), isA<ValidationFailure>());
      expect(await totalTransacoes(), 0);
      expect((await todas()).single.paga, isFalse);
    });

    test('pagar duas vezes a mesma conta não duplica a despesa', () async {
      final c = await criar(recorrencia: RecorrenciaConta.nenhuma);
      _ok(await marcarComoPaga(conta: c, valorPago: 100));

      final paga = (await todas()).single;
      final segunda = await marcarComoPaga(conta: paga, valorPago: 100);

      expect(_falha(segunda), isA<ValidationFailure>());
      expect(await totalTransacoes(), 1);
    });

    test('se marcar como paga falha, a despesa criada é desfeita', () async {
      final quebrado = MarcarContaComoPagaUseCase(
        contas: _ContaQueFalhaAoPagar(ContaLocalDataSource(db)),
        transacoes: transacoes,
        agora: () => agora,
      );
      final c = await criar();

      final r = await quebrado(conta: c, valorPago: 100);

      expect(r.isLeft(), isTrue);
      expect(await totalTransacoes(), 0);
      expect((await todas()).single.paga, isFalse);
    });

    group('conta recorrente', () {
      test('mensal: ao pagar, a próxima do mês seguinte já aparece', () async {
        final c = await criar(vencimento: DateTime(2026, 11, 10));

        _ok(await marcarComoPaga(conta: c, valorPago: 1480));

        final lista = await todas();
        expect(lista, hasLength(2));
        final proxima = lista.firstWhere((x) => !x.paga);
        expect(proxima.vencimento, DateTime(2026, 12, 10));
        expect(proxima.descricao, 'Aluguel');
        expect(proxima.valor, 1500); // o esperado, não o pago deste mês
        expect(proxima.recorrencia, RecorrenciaConta.mensal);
        expect(proxima.categoria, 'Moradia');
      });

      test('a próxima mantém o dia-base: 31 em mês curto e de volta ao 31', () async {
        var atual = await criar(vencimento: DateTime(2026, 1, 31));
        final vencimentos = <DateTime>[];

        for (var i = 0; i < 3; i++) {
          _ok(await marcarComoPaga(conta: atual, valorPago: 100));
          atual = (await todas()).firstWhere((x) => !x.paga);
          vencimentos.add(atual.vencimento);
        }

        expect(vencimentos, [DateTime(2026, 2, 28), DateTime(2026, 3, 31), DateTime(2026, 4, 30)]);
      });

      test('anual: a próxima é no ano seguinte', () async {
        final c = await criar(vencimento: DateTime(2026, 11, 20), recorrencia: RecorrenciaConta.anual);

        _ok(await marcarComoPaga(conta: c, valorPago: 2400));

        expect((await todas()).firstWhere((x) => !x.paga).vencimento, DateTime(2027, 11, 20));
      });

      test('conta que não se repete não gera próxima', () async {
        final c = await criar(recorrencia: RecorrenciaConta.nenhuma);

        _ok(await marcarComoPaga(conta: c, valorPago: 100));

        expect(await todas(), hasLength(1));
      });

      test('se a próxima já existe, não duplica', () async {
        final c = await criar(vencimento: DateTime(2026, 11, 10));
        await criar(vencimento: DateTime(2026, 12, 10)); // já veio de outro lugar

        _ok(await marcarComoPaga(conta: c, valorPago: 100));

        final abertas = (await todas()).where((x) => !x.paga).toList();
        expect(abertas, hasLength(1));
      });
    });
  });
}
