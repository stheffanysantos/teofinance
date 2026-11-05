import 'package:fpdart/fpdart.dart';

import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/categoria/domain/repositories/categoria_repository.dart';
import 'package:teofinance/features/categoria/domain/usecases/adicionar_categoria_usecase.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';

/// Renomeia uma categoria do usuário e leva junto as transações que a usavam,
/// para o histórico não ficar com um nome que deixou de existir.
class RenomearCategoriaUseCase {
  RenomearCategoriaUseCase(this._categorias, this._transacoes);

  final CategoriaRepository _categorias;
  final TransacaoRepository _transacoes;

  Future<Either<Failure, Unit>> call({
    required String nomeAtual,
    required String novoNome,
    required List<String> existentes,
  }) async {
    final limpo = novoNome.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (limpo == nomeAtual) {
      return const Right(unit);
    }
    if (limpo.isEmpty) {
      return const Left(ValidationFailure('Informe o nome da categoria.'));
    }
    if (limpo.length > kTamanhoMaximoCategoria) {
      return const Left(
        ValidationFailure('Use até $kTamanhoMaximoCategoria caracteres.'),
      );
    }
    final minusculo = limpo.toLowerCase();
    final outras = existentes.where((c) => c != nomeAtual);
    if ([
      ...kCategoriasBase,
      ...outras,
    ].any((c) => c.toLowerCase() == minusculo)) {
      return const Left(
        ValidationFailure('Já existe uma categoria com esse nome.'),
      );
    }

    final criou = await _categorias.adicionar(limpo);
    if (criou.isLeft()) return criou;

    final todas = await _transacoes.observarTodas().first;
    for (final t in todas.where((t) => t.categoria == nomeAtual)) {
      await _transacoes.categorizar(id: t.id, categoria: limpo);
    }
    return _categorias.remover(nomeAtual);
  }
}
