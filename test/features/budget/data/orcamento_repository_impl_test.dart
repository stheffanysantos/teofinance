import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/database/app_database.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/budget/data/datasources/orcamento_local_datasource.dart';
import 'package:teofinance/features/budget/data/repositories/orcamento_repository_impl.dart';
import 'package:teofinance/features/budget/domain/entities/orcamento.dart';
import 'package:teofinance/features/budget/domain/usecases/definir_limite_orcamento_usecase.dart';
import 'package:teofinance/features/budget/domain/usecases/excluir_limite_orcamento_usecase.dart';

Failure _falha<T>(Either<Failure, T> r) => r.swap().getOrElse((_) => throw StateError('esperava Left'));

void main() {
  late AppDatabase db;
  late OrcamentoRepositoryImpl repository;
  late DefinirLimiteOrcamentoUseCase definir;
  late ExcluirLimiteOrcamentoUseCase excluir;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = OrcamentoRepositoryImpl(OrcamentoLocalDataSource(db));
    definir = DefinirLimiteOrcamentoUseCase(repository);
    excluir = ExcluirLimiteOrcamentoUseCase(repository);
  });

  tearDown(() => db.close());

  Future<List<Orcamento>> todos() => repository.observarTodos().first;

  test('define o limite e ele persiste', () async {
    final r = await definir(categoria: 'Mercado', limite: 500);

    expect(r.isRight(), isTrue);
    final salvos = await todos();
    expect(salvos.single.categoria, 'Mercado');
    expect(salvos.single.limite, 500);
  });

  test('definir de novo a mesma categoria troca o valor sem duplicar', () async {
    await definir(categoria: 'Mercado', limite: 500);
    final segundo = await definir(categoria: 'Mercado', limite: 650);

    final salvos = await todos();
    expect(salvos, hasLength(1));
    expect(salvos.single.limite, 650);
    expect(salvos.single.id, segundo.getOrElse((_) => throw StateError('esperava Right')).id);
  });

  test('recusa limite zero, negativo e categoria vazia sem gravar nada', () async {
    expect(_falha(await definir(categoria: 'Mercado', limite: 0)), isA<ValidationFailure>());
    expect(_falha(await definir(categoria: 'Mercado', limite: -10)), isA<ValidationFailure>());
    expect(_falha(await definir(categoria: '  ', limite: 100)), isA<ValidationFailure>());
    expect(await todos(), isEmpty);
  });

  test('exclui o limite pelo id', () async {
    final criado = (await definir(categoria: 'Lazer', limite: 200)).getOrElse((_) => throw StateError('x'));

    final r = await excluir(criado.id);

    expect(r.isRight(), isTrue);
    expect(await todos(), isEmpty);
  });

  test('excluir com id vazio é recusado', () async {
    expect(_falha(await excluir('')), isA<ValidationFailure>());
  });

  test('a lista sai ordenada por categoria', () async {
    await definir(categoria: 'Transporte', limite: 100);
    await definir(categoria: 'Lazer', limite: 100);

    expect((await todos()).map((o) => o.categoria), ['Lazer', 'Transporte']);
  });
}
