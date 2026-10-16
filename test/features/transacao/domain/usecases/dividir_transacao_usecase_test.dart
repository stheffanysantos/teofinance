import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';
import 'package:teofinance/features/transacao/domain/usecases/dividir_transacao_usecase.dart';
import 'package:teofinance/features/transacao/domain/usecases/remover_divisao_usecase.dart';

class _FakeRepository implements TransacaoRepository {
  final chamadas = <({String id, double? minhaParte, List<String> pessoas})>[];

  @override
  Future<Either<Failure, Unit>> definirDivisao({
    required String id,
    required double? minhaParte,
    List<String> divididoCom = const [],
  }) async {
    chamadas.add((id: id, minhaParte: minhaParte, pessoas: divididoCom));
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeRepository repository;
  late DividirTransacaoUseCase usecase;

  setUp(() {
    repository = _FakeRepository();
    usecase = DividirTransacaoUseCase(repository);
  });

  test('caminho feliz grava a parte e os nomes sem espaços sobrando', () async {
    final r = await usecase(id: 't1', valorTotal: -100, minhaParte: 33.33, pessoas: [' Ana ', 'Bruno', '']);

    expect(r.isRight(), isTrue);
    expect(repository.chamadas.single.minhaParte, 33.33);
    expect(repository.chamadas.single.pessoas, ['Ana', 'Bruno']);
  });

  test('exige ao menos uma pessoa', () async {
    final r = await usecase(id: 't1', valorTotal: -100, minhaParte: 50, pessoas: ['  ']);

    expect(r.isLeft(), isTrue);
    expect(repository.chamadas, isEmpty);
  });

  test('rejeita parte zero, negativa ou maior que o total', () async {
    expect((await usecase(id: 't1', valorTotal: -100, minhaParte: 0, pessoas: ['Ana'])).isLeft(), isTrue);
    expect((await usecase(id: 't1', valorTotal: -100, minhaParte: -5, pessoas: ['Ana'])).isLeft(), isTrue);
    expect((await usecase(id: 't1', valorTotal: -100, minhaParte: 100.01, pessoas: ['Ana'])).isLeft(), isTrue);
    expect(repository.chamadas, isEmpty);
  });

  test('aceita a parte igual ao total', () async {
    final r = await usecase(id: 't1', valorTotal: -100, minhaParte: 100, pessoas: ['Ana']);

    expect(r.isRight(), isTrue);
  });

  test('remover divisão envia minhaParte nulo', () async {
    await RemoverDivisaoUseCase(repository)('t1');

    expect(repository.chamadas.single.minhaParte, isNull);
  });
}
