import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/parcelamento/domain/entities/parcelamento.dart';
import 'package:teofinance/features/parcelamento/domain/repositories/parcelamento_repository.dart';
import 'package:teofinance/features/parcelamento/domain/usecases/criar_parcelamento_usecase.dart';

class _FakeRepository implements ParcelamentoRepository {
  int chamadas = 0;
  Either<Failure, Parcelamento>? resposta;

  @override
  Future<Either<Failure, Parcelamento>> criarParcelamento({
    required String transacaoId,
    required double totalOriginal,
    required int numeroParcelas,
    required DateTime dataPrimeira,
  }) async {
    chamadas++;
    return resposta ??
        Right(Parcelamento(
          id: 'p1',
          transacaoOriginalId: transacaoId,
          totalOriginal: totalOriginal,
          numeroParcelas: numeroParcelas,
          dataPrimeiraParc: dataPrimeira,
          updatedAt: dataPrimeira,
        ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

CriarParcelamentoParams _params({double total = 300, int parcelas = 3}) => CriarParcelamentoParams(
      transacaoId: 't1',
      totalOriginal: total,
      numeroParcelas: parcelas,
      dataPrimeira: DateTime(2026, 10, 10),
    );

void main() {
  late _FakeRepository repository;
  late CriarParcelamentoUseCase usecase;

  setUp(() {
    repository = _FakeRepository();
    usecase = CriarParcelamentoUseCase(repository);
  });

  test('caminho feliz devolve o parcelamento com valor da parcela', () async {
    final resultado = await usecase(_params());

    final parcelamento = resultado.getOrElse((_) => throw StateError('esperava Right'));
    expect(parcelamento.numeroParcelas, 3);
    expect(parcelamento.valorParcela, 100);
    expect(repository.chamadas, 1);
  });

  test('rejeita menos de 2 parcelas sem chamar o repository', () async {
    final resultado = await usecase(_params(parcelas: 1));

    expect(resultado.isLeft(), isTrue);
    expect(repository.chamadas, 0);
  });

  test('rejeita mais de 12 parcelas', () async {
    final resultado = await usecase(_params(parcelas: 13));

    expect(resultado.isLeft(), isTrue);
    expect(repository.chamadas, 0);
  });

  test('rejeita valor zero ou negativo', () async {
    expect((await usecase(_params(total: 0))).isLeft(), isTrue);
    expect((await usecase(_params(total: -50))).isLeft(), isTrue);
    expect(repository.chamadas, 0);
  });

  test('propaga a falha do repository', () async {
    repository.resposta = Left(ServerFailure('falhou'));

    final resultado = await usecase(_params());

    expect(resultado.isLeft(), isTrue);
  });
}
