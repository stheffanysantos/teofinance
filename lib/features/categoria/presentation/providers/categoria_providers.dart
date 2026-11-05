import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teofinance/core/constants/categorias.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/features/categoria/data/datasources/categoria_local_data_source.dart';
import 'package:teofinance/features/categoria/data/repositories/categoria_repository_impl.dart';
import 'package:teofinance/features/categoria/domain/repositories/categoria_repository.dart';
import 'package:teofinance/features/categoria/domain/usecases/adicionar_categoria_usecase.dart';
import 'package:teofinance/features/categoria/domain/usecases/remover_categoria_usecase.dart';
import 'package:teofinance/features/categoria/domain/usecases/renomear_categoria_usecase.dart';
import 'package:teofinance/features/transacao/presentation/providers/transacao_providers.dart';

final categoriaRepositoryProvider = Provider<CategoriaRepository>((ref) {
  return CategoriaRepositoryImpl(
    CategoriaLocalDataSource(ref.watch(appDatabaseProvider)),
  );
});

final adicionarCategoriaUseCaseProvider = Provider((ref) {
  return AdicionarCategoriaUseCase(ref.watch(categoriaRepositoryProvider));
});

final renomearCategoriaUseCaseProvider = Provider((ref) {
  return RenomearCategoriaUseCase(
    ref.watch(categoriaRepositoryProvider),
    ref.watch(transacaoRepositoryProvider),
  );
});

final removerCategoriaUseCaseProvider = Provider((ref) {
  return RemoverCategoriaUseCase(ref.watch(categoriaRepositoryProvider));
});

/// Só as categorias criadas pelo usuário. Recarrega com `ref.invalidate`
/// depois de adicionar ou remover.
final categoriasPersonalizadasProvider = FutureProvider<List<String>>((
  ref,
) async {
  final resultado = await ref.watch(categoriaRepositoryProvider).listar();
  return resultado.getOrElse((_) => const []);
});

/// Todas as categorias atribuíveis a uma transação: padrão + do usuário.
final categoriasProvider = Provider<List<String>>((ref) {
  final proprias =
      ref.watch(categoriasPersonalizadasProvider).valueOrNull ?? const [];
  return [...kCategorias, ...proprias];
});

/// Opções do filtro da lista de transações ("Todas" + categorias).
final categoriasFiltroProvider = Provider<List<String>>((ref) {
  return ['Todas', ...ref.watch(categoriasProvider)];
});
