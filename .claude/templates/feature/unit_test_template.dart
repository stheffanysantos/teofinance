import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/nome_feature/domain/entities/nome_entidade.dart';
import 'package:teofinance/features/nome_feature/domain/repositories/nome_entidade_repository.dart';
import 'package:teofinance/features/nome_feature/domain/usecases/salvar_nome_entidade_usecase.dart';

class _MockRepository extends Mock implements NomeEntidadeRepository {}

void main() {
  late _MockRepository repository;
  late SalvarNomeEntidadeUseCase usecase;

  setUp(() {
    repository = _MockRepository();
    usecase = SalvarNomeEntidadeUseCase(repository);
  });

  final entidadeValida = NomeEntidade(descricao: 'Teste', valor: 100, data: DateTime(2026, 1, 1));

  test('caminho feliz: salva quando o valor é válido', () async {
    when(() => repository.salvar(entidadeValida))
        .thenAnswer((_) async => Right(entidadeValida));

    final resultado = await usecase(entidadeValida);

    expect(resultado.isRight(), true);
    verify(() => repository.salvar(entidadeValida)).called(1);
  });

  test('caminho de falha: rejeita valor zero antes de chamar o repository', () async {
    final entidadeInvalida = entidadeValida.copyWith(valor: 0);

    final resultado = await usecase(entidadeInvalida);

    expect(resultado, const Left(ValidationFailure('Valor deve ser diferente de zero.')));
    verifyNever(() => repository.salvar(any()));
  });
}
